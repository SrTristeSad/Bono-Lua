'use strict';
// Audit infrastructure only. The product runtime is Lua.
const fs = require('fs');
const path = require('path');
const cp = require('child_process');
const ts = require('typescript');
const PIN = '64b6c69ae35777c2404be68c9192e2c56906079e';
const progress = JSON.parse(fs.readFileSync(path.join(__dirname,'../docs/PORTING_PROGRESS.json'),'utf8'));
if (progress.upstream_commit !== PIN) throw Error('Progress must reference pinned commit');
const source = path.resolve(process.argv[2] || '../DragonBonesJS');
const check = process.argv.includes('--check');
const git = (...args) => cp.execFileSync('git', ['-C', source, ...args], {encoding: 'utf8', maxBuffer: 32*1024*1024});
if (git('rev-parse', 'HEAD').trim() !== PIN) throw Error('Upstream HEAD must equal pinned commit');
// Read Git blobs, never potentially modified worktree files.
const files = git('ls-tree', '-r', '--name-only', PIN).trim().split('\n');
for (const [origin, entry] of Object.entries(progress.files)) {
  if (!files.includes(origin) || !fs.existsSync(path.join(__dirname,'..',entry.destination)))
    throw Error('Progress references missing source/destination: '+origin);
}
function category(p) {
  if (p === 'Cocos/Demos/packages/dragonbones/assets/dragonBones.js') return 'Arquivo gerado ou dependência distribuída';
  if (/\.d\.ts$/.test(p)) return 'Interface ou declaração de tipos';
  if (/\/(?:libs|out|bin-release|bin-debug)\//.test(p) || /\.min\.js$/.test(p)) return 'Arquivo gerado ou dependência distribuída';
  if (/\.(png|jpg|jpeg|gif|webp|dbbin|dbdt|fnt|mp3|wav|ttf|plist|atlas)$/.test(p) || /\/(?:resource|resources)\//.test(p)) return 'Recurso gráfico ou dados';
  if (/\.(meta|fire|prefab)$/.test(p)) return 'Configuração';
  if (/(?:test|spec)(?:\.|\/)/i.test(p) && !/Demos/.test(p)) return 'Teste';
  if (/\.md$/.test(p) || /license/i.test(p)) return 'Documentação';
  if (/\.ts$/.test(p) && /\binterface\b/.test(git('show', PIN+':'+p)) && !/\bclass\b/.test(git('show', PIN+':'+p))) return 'Interface ou declaração de tipos';
  if (p.startsWith('DragonBones/src/')) return 'Código-fonte do núcleo';
  if (/\/src\/dragonBones\//.test(p)) return 'Integração com motor gráfico';
  if (/^Cocos\/Demos\/packages\/dragonbones\/(editor\/|main\.js|scene\.js)/.test(p) || /^Egret\/Demos\/template\/runtime\/.*\.js$/.test(p)) return 'Integração de editor ou carregador de plataforma';
  if (/Demos\//.test(p)) return 'Demonstração';
  if ((p.startsWith('builds/') || p === 'package.json.js' || p === 'Egret/4.x/scripts/modify.js') && /\.js$/.test(p)) return 'Configuração (ferramenta de build executável)';
  return 'Configuração';
}
function destination(p, cat) {
  if (progress.files[p]) return progress.files[p].destination;
  if (p.startsWith('DragonBones/src/')) return p.replace('DragonBones/src/dragonBones/', 'dragonbones/').replace(/\.ts$/, '.lua');
  if (cat.startsWith('Integração')) return 'integrations/'+p.replace(/\.(ts|js)$/, '.lua');
  return '—';
}
const entries = files.map(p => ({p, cat: category(p)}));
// Include authored TS and JS, including editor plugins and native loaders.
// Distributed JS bundles and
// declarations remain catalogued, but are not counted as runtime modules.
const functional = entries.filter(e => !/\.d\.ts$/.test(e.p) && /\.(ts|js)$/.test(e.p) &&
  !/\/(libs|out)\//.test(e.p) && !e.cat.startsWith('Arquivo gerado'));
const units = functional.map(e => {
  const text = git('show', PIN+':'+e.p);
  const ast = ts.createSourceFile(e.p, text, ts.ScriptTarget.Latest, true);
  if (ast.parseDiagnostics.length) throw Error('Parse diagnostics in '+e.p);
  const declarations = [], topLevel = [], references = new Set(), externals = new Set();
  const compact = s => s.replace(/\s+/g, ' ').trim();
  function namespaceLevel(n) {
    for (let p=n.parent;p;p=p.parent) {
      if ([ts.SyntaxKind.ClassDeclaration,ts.SyntaxKind.FunctionDeclaration,ts.SyntaxKind.FunctionExpression,
        ts.SyntaxKind.ArrowFunction,ts.SyntaxKind.MethodDeclaration,ts.SyntaxKind.Constructor,
        ts.SyntaxKind.GetAccessor,ts.SyntaxKind.SetAccessor].includes(p.kind)) return false;
    }
    return true;
  }
  function namedFunction(name,node,kind) {
    declarations.push({name,kind,heritage:[],methods:[{name,
      signature:compact(node.body ? text.slice(node.getStart(ast),node.body.getStart(ast)) : node.getText(ast)),
      line:ast.getLineAndCharacterOfPosition(node.getStart(ast)).line+1}],properties:[]});
  }
  function visit(n) {
    if (n.kind === ts.SyntaxKind.Identifier) references.add(n.text);
    if (n.kind === ts.SyntaxKind.ClassDeclaration || n.kind === ts.SyntaxKind.InterfaceDeclaration) {
      const methods = [], properties = [];
      for (const m of n.members) {
        const name = m.name ? m.name.getText(ast) : 'constructor';
        const isMethod = [ts.SyntaxKind.Constructor, ts.SyntaxKind.MethodDeclaration, ts.SyntaxKind.MethodSignature,
          ts.SyntaxKind.GetAccessor, ts.SyntaxKind.SetAccessor, ts.SyntaxKind.CallSignature, ts.SyntaxKind.ConstructSignature].includes(m.kind);
        const signature = compact(m.body ? text.slice(m.getStart(ast), m.body.getStart(ast)) : m.getText(ast));
        (isMethod ? methods : properties).push({name, signature, line: ast.getLineAndCharacterOfPosition(m.getStart(ast)).line+1});
      }
      declarations.push({name: n.name ? n.name.text : '(anônimo)', kind: ts.SyntaxKind[n.kind],
        heritage: (n.heritageClauses || []).map(h => compact(h.getText(ast))), methods, properties});
    } else if (n.kind === ts.SyntaxKind.EnumDeclaration) {
      declarations.push({name:n.name.text, kind:'EnumDeclaration', heritage:[], methods:[],
        properties: n.members.map(m => ({name:m.name.getText(ast),signature:compact(m.getText(ast)),line:ast.getLineAndCharacterOfPosition(m.getStart(ast)).line+1}))});
    } else if (n.kind === ts.SyntaxKind.FunctionDeclaration) {
      declarations.push({name:n.name ? n.name.text : '(anônima)', kind:'FunctionDeclaration', heritage:[], methods:[{name:n.name ? n.name.text : '(anônima)', signature:compact(n.body ? text.slice(n.getStart(ast),n.body.getStart(ast)) : n.getText(ast)),line:ast.getLineAndCharacterOfPosition(n.getStart(ast)).line+1}],properties:[]});
    } else if (n.kind === ts.SyntaxKind.VariableDeclaration && namespaceLevel(n)) {
      if (n.initializer && [ts.SyntaxKind.FunctionExpression,ts.SyntaxKind.ArrowFunction].includes(n.initializer.kind)) namedFunction(n.name.getText(ast),n.initializer,'NamespaceFunction');
      else declarations.push({name:n.name.getText(ast),kind:'NamespaceVariable',heritage:[],methods:[],properties:[{
        name:n.name.getText(ast),signature:compact(n.getText(ast)),line:ast.getLineAndCharacterOfPosition(n.getStart(ast)).line+1}]});
    } else if (n.kind === ts.SyntaxKind.MethodDeclaration && n.parent.kind === ts.SyntaxKind.ObjectLiteralExpression) {
      namedFunction(n.name.getText(ast),n,'ObjectMemberFunction');
    } else if (n.kind === ts.SyntaxKind.PropertyAssignment && n.initializer && [ts.SyntaxKind.FunctionExpression,ts.SyntaxKind.ArrowFunction].includes(n.initializer.kind)) {
      namedFunction(n.name.getText(ast),n.initializer,'ObjectMemberFunction');
    } else if (n.kind === ts.SyntaxKind.BinaryExpression && n.operatorToken.kind===ts.SyntaxKind.EqualsToken && [ts.SyntaxKind.FunctionExpression,ts.SyntaxKind.ArrowFunction].includes(n.right.kind)) {
      namedFunction(n.left.getText(ast),n.right,'FunctionAssignment');
    }
    if (n.kind===ts.SyntaxKind.ExpressionStatement && namespaceLevel(n)) topLevel.push({
      line:ast.getLineAndCharacterOfPosition(n.getStart(ast)).line+1,expression:compact(n.getText(ast))});
    if (n.kind === ts.SyntaxKind.CallExpression && n.expression.getText(ast) === 'require' && n.arguments.length) externals.add(n.arguments[0].getText(ast));
    if (n.kind === ts.SyntaxKind.ImportDeclaration) externals.add(n.moduleSpecifier.getText(ast));
    ts.forEachChild(n, visit);
  }
  visit(ast);
  return {...e, declarations, topLevel, references, externals, target:destination(e.p,e.cat)};
});
const owners = new Map();
for (const u of units) for (const d of u.declarations) {
  if (!owners.has(d.name)) owners.set(d.name,new Set());
  owners.get(d.name).add(u.p);
}
const esc = s => String(s).replace(/\|/g,'\\|').replace(/\n/g,' ');
let md = '# Inventário integral do upstream\n\n'+
  'Fonte: DragonBones/DragonBonesJS@`'+PIN+'`. Gerado de blobs Git por `node tools/inventory.js ../DragonBonesJS`.\n\n'+
  'Todos os '+files.length+' arquivos rastreados estão abaixo. '+units.length+' arquivos autorais TS/JS são examinados por AST, incluindo demonstrações e ferramentas. Declarações distribuídas e bundles não são novos módulos de runtime.\n\n'+
  '**Estado:** inventário de arquivos e declarações disponível; a situação por módulo vem de PORTING_PROGRESS.json. Dependências candidatas abaixo são heurísticas históricas; a resolução por símbolos e contextos isolados está em DEPENDENCIES.md. Referências externas não resolvidas e contratos dinâmicos permanecem explícitos para validação nas etapas de integração. Nenhuma contagem comprova equivalência integral.\n\n'+
  '| Origem | Categoria | Destino previsto | Estado |\n| --- | --- | --- | --- |\n';
for (const e of entries) md += '| `'+e.p+'` | '+e.cat+' | '+destination(e.p,e.cat)+' | '+(progress.files[e.p] ? progress.files[e.p].status : 'Inventariado; implementação/validação pendente ou não aplicável à categoria')+' |\n';
md += '\n## Contratos por arquivo autoral\n\nMétodos e propriedades incluem membros privados, estáticos, construtores, getters e setters declarados no arquivo; membros herdados são vinculados por `extends`/`implements`. Enumerações são listadas separadamente de classes. Assinaturas contêm inicializadores de campos e números de linha. Nenhuma presença no inventário comprova equivalência.\n';
for (const u of units) {
  const state = progress.files[u.p];
  const deps = new Set();
  for (const ref of u.references) for (const owner of owners.get(ref) || []) if (owner !== u.p) deps.add(owner);
  md += '\n### `'+u.p+'`\n\n'+
    '- Origem/commit: `'+u.p+'` @ `'+PIN+'`.\n'+
    '- Destino: '+u.target+'. '+(state ? (state.kind === 'contract' ? 'Contrato documentado; interface sem algoritmo executável.' : 'Implementação presente nesta reconstrução.') : 'Ausente nesta reconstrução antes de iniciar o porte.')+'\n'+
    '- Estado: '+(state ? state.status+'; testes: '+state.tests+'; diferenças: '+state.differences : 'pendente; testes: não executados; diferenças: ainda não auditadas.')+'\n'+
    '- Dependências candidatas: '+([...deps].sort().map(x=>'`'+x+'`').join(', ') || 'nenhuma declaração autoral identificada')+'.\n'+
    '- Importações externas: '+([...u.externals].sort().join(', ') || 'nenhuma importação explícita; APIs globais ainda exigem auditoria')+'.\n';
  if (u.topLevel.length) {
    md+='\nExecução no escopo de arquivo/namespace (não executada pelo inventário):\n\n';
    for(const stmt of u.topLevel) md+='- Linha '+stmt.line+': `'+esc(stmt.expression).replace(/`/g,"'")+'`\n';
  }
  for (const d of u.declarations) {
    md += '\n#### '+d.kind+' `'+d.name+'`\n\nHerança: '+(d.heritage.join('; ') || 'nenhuma explícita')+'.\n\n| Membro | Tipo | Assinatura original | Linha |\n| --- | --- | --- | --- |\n';
    for (const [kind, members] of [['método',d.methods],['propriedade',d.properties]])
      for (const m of members) md += '| `'+esc(m.name)+'` | '+kind+' | `'+esc(m.signature).replace(/`/g,"'")+'` | '+m.line+' |\n';
  }
  if (!u.declarations.length) md += '\nSem classes/interfaces/enums/funções nomeadas declaradas. Revisar instruções de topo, exports e callbacks no arquivo original.\n';
}
const out = path.join(__dirname, '../docs/UPSTREAM_INVENTORY.md');
if (check) {
  if (fs.readFileSync(out,'utf8') !== md) throw Error('Inventory differs from pinned source');
} else fs.writeFileSync(out,md);
console.log(JSON.stringify({commit:PIN,files:files.length,authoredUnits:units.length,
  classes:units.reduce((n,u)=>n+u.declarations.filter(d=>d.kind==='ClassDeclaration').length,0),
  categories:entries.reduce((a,e)=>(a[e.cat]=(a[e.cat]||0)+1,a),{}),mode:check?'check':'generate'}));
