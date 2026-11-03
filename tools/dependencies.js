'use strict';
// Inventory infrastructure, never part of the Lua runtime.
const fs = require('fs');
const path = require('path');
const cp = require('child_process');
const ts = require('typescript');
const PIN = '64b6c69ae35777c2404be68c9192e2c56906079e';
const root = path.resolve(process.argv[2] || '../DragonBonesJS');
const check = process.argv.includes('--check');
const git = (...args) => cp.execFileSync('git', ['-C',root,...args], {encoding:'utf8',maxBuffer:32*1024*1024});
if (git('rev-parse','HEAD').trim() !== PIN) throw Error('Wrong upstream HEAD');
const paths = git('ls-tree','-r','--name-only',PIN).trim().split('\n');
const texts = new Map();
for (const p of paths.filter(p => /\.(ts|js)$/.test(p) || /tsconfig\.json$/.test(p))) texts.set(p,git('show',PIN+':'+p));
const configs = paths.filter(p => p.endsWith('/tsconfig.json'));
const owner = p => configs.filter(c => p.startsWith(path.posix.dirname(c)+'/'))
  .sort((a,b)=>b.length-a.length)[0];
const authored = paths.filter(p => /\.ts$/.test(p) && !/\.d\.ts$/.test(p) && !/\/(libs|out)\//.test(p));
const authoredJS = paths.filter(p => /\.js$/.test(p) && !/\/(libs|out)\//.test(p) && !/\.min\.js$/.test(p) && p!=='Cocos/Demos/packages/dragonbones/assets/dragonBones.js');
const core = authored.filter(p=>p.startsWith('DragonBones/src/'));
const results = new Map();
const unresolvedInputs = [];
const normalize = p => p.replace(/\\/g,'/');
const virtual = p => '/upstream/'+p;
for (const config of configs) {
  const owned = authored.filter(p=>owner(p)===config);
  if (!owned.length) continue;
  const base = path.posix.dirname(config);
  const parsed = ts.parseConfigFileTextToJson(config,texts.get(config));
  if (parsed.error) throw Error('Bad config '+config);
  const requested = (parsed.config.files || []).map(p=>path.posix.normalize(base+'/'+p));
  for (const p of requested) if (!texts.has(p)) unresolvedInputs.push({config,path:p});
  // Keep engines and demo packages isolated: the duplicate names of different
  // backend versions must never be merged into a single global namespace.
  const roots = new Set(owned);
  for (const p of paths) if (/\.d\.ts$/.test(p) && !/\/out\//.test(p) && owner(p)===config) roots.add(p);
  for (const p of requested) if (texts.has(p) && /\.ts$/.test(p)) roots.add(p);
  if (owned.some(p=>/\/src\/dragonBones\//.test(p))) for (const p of core) roots.add(p);
  const options = {target:ts.ScriptTarget.ES5,experimentalDecorators:true,noEmit:true};
  const host = ts.createCompilerHost(options);
  const oldRead = host.readFile.bind(host), oldExists = host.fileExists.bind(host);
  host.getCurrentDirectory = () => '/upstream';
  host.readFile = p => normalize(p).startsWith('/upstream/') ? texts.get(normalize(p).slice(10)) : oldRead(p);
  host.fileExists = p => normalize(p).startsWith('/upstream/') ? texts.has(normalize(p).slice(10)) : oldExists(p);
  host.directoryExists = p => normalize(p).startsWith('/upstream') ? paths.some(f=>virtual(f).startsWith(normalize(p)+'/')) : ts.sys.directoryExists(p);
  host.getSourceFile = (p,version) => {
    const text = host.readFile(p);
    return text === undefined ? undefined : ts.createSourceFile(p,text,version,true);
  };
  const program = ts.createProgram([...roots].map(virtual),options,host);
  const checker = program.getTypeChecker();
  for (const p of owned) {
    const ast = program.getSourceFile(virtual(p));
    if (!ast || ast.parseDiagnostics.length) throw Error('Cannot parse '+p);
    const dependencies = new Set(), externalFiles = new Set(), unresolved = new Set(), apis = new Set();
    function visit(n) {
      if (n.kind===ts.SyntaxKind.Identifier) {
        const symbol = checker.getSymbolAtLocation(n);
        if (symbol) {
          for (const d of symbol.declarations || []) {
            // Namespace declarations themselves would spuriously connect all
            // files contributing to dragonBones. Actual class/member uses do.
            if (d.kind===ts.SyntaxKind.ModuleDeclaration) continue;
            const f=normalize(d.getSourceFile().fileName);
            if (f.startsWith('/upstream/')) {
              const rel=f.slice(10);
              if (rel!==p) (/\.d\.ts$/.test(rel)?externalFiles:dependencies).add(rel);
            }
          }
        } else {
          const par=n.parent;
          const memberName = (par.kind===ts.SyntaxKind.PropertyAccessExpression && par.name===n) ||
            (par.name===n && par.kind!==ts.SyntaxKind.ShorthandPropertyAssignment);
          if (!memberName) unresolved.add(n.text);
        }
      }
      if (n.kind===ts.SyntaxKind.PropertyAccessExpression) {
        let head=n;
        while (head.kind===ts.SyntaxKind.PropertyAccessExpression) head=head.expression;
        if (head.kind===ts.SyntaxKind.Identifier) {
          const sym=checker.getSymbolAtLocation(head);
          if (!sym || (sym.declarations || []).some(d=>!normalize(d.getSourceFile().fileName).startsWith('/upstream/') || /\.d\.ts$/.test(d.getSourceFile().fileName)))
            apis.add(n.getText(ast));
        }
      }
      ts.forEachChild(n,visit);
    }
    visit(ast);
    results.set(p,{config,dependencies:[...dependencies].sort(),externalFiles:[...externalFiles].sort(),unresolved:[...unresolved].sort(),apis:[...apis].sort()});
  }
}
if (results.size!==authored.length) throw Error('Unassigned authored TS file');
let out='# Dependências e fronteiras de plataforma\n\nFonte única: DragonBones/DragonBonesJS@`'+PIN+'`. Gerado por `node tools/dependencies.js ../DragonBonesJS`.\n\n'+
  'Resolução de símbolos TypeScript 2.4.2 por pacote/tsconfig, separando versões dos backends. Arquivos lidos de blobs Git. Bibliotecas padrão do compilador são infraestrutura de análise. As arestas incluem usos em tipos e em execução; não equivalem à ordem de inicialização. Símbolos dinâmicos e nomes não resolvidos permanecem explicitamente pendentes, sem inventar APIs Lua. Esta análise não valida comportamento.\n\n'+
  'A auditoria de inventário é completa quanto aos caminhos, declarações e referências estáticas disponíveis. A fidelidade dos contratos externos será verificada nas etapas 09/10, sem bloquear o porte das classes geom independentes.\n\n'+
  '## Entradas externas ausentes no commit\n\n'+unresolvedInputs.map(e=>'- `'+e.config+'` solicita `'+e.path+'`.').join('\n')+'\n\n'+
  '## Dependências por arquivo autoral TypeScript\n\n';
for (const p of [...results.keys()].sort()) {
  const r=results.get(p), list=a=>a.length?a.map(x=>'`'+x.replace(/`/g,"'")+'`').join(', '):'nenhuma';
  out+='### `'+p+'`\n\n'+
    '- Contexto isolado: `'+r.config+'`.\n'+
    '- Arquivos autorais resolvidos: '+list(r.dependencies)+'.\n'+
    '- Declarações externas/distribuídas: '+list(r.externalFiles)+'.\n'+
    '- Nomes sem resolução estática: '+list(r.unresolved)+'.\n'+
    '- Acessos a APIs externas/globais: '+list(r.apis)+'.\n\n';
}
out+='## JavaScript autoral: imports e efeitos de plataforma\n\n'+
  'Os arquivos abaixo também pertencem ao escopo de inventário. As declarações e instruções de topo estão em UPSTREAM_INVENTORY.md. O inventário não os executa; plugins de editor/carregadores e ferramentas não são contados como classes do núcleo. Imports dinâmicos e contratos do host permanecem pendentes para as etapas de integração.\n\n'+
  '| Origem | require explícito | Dependências locais resolvidas no commit |\n| --- | --- | --- |\n';
for (const p of authoredJS) {
  const ast=ts.createSourceFile(p,texts.get(p),ts.ScriptTarget.Latest,true);
  const imports=new Set(),local=new Set();
  function visit(n) {
    if(n.kind===ts.SyntaxKind.CallExpression && n.expression.getText(ast)==='require' && n.arguments.length) {
      const arg=n.arguments[0];imports.add(arg.getText(ast));
      if(arg.kind===ts.SyntaxKind.StringLiteral && arg.text.startsWith('.')) {
        const base=path.posix.normalize(path.posix.dirname(p)+'/'+arg.text);
        const resolved=[base,base+'.js',base+'/index.js'].find(p=>texts.has(p));
        local.add(resolved || 'AUSENTE: '+base);
      }
    }
    ts.forEachChild(n,visit);
  }
  visit(ast);
  out+='| `'+p+'` | '+([...imports].sort().join(', ') || 'nenhum')+' | '+([...local].sort().map(p=>'`'+p+'`').join(', ') || 'nenhuma')+' |\n';
}
out+='\n`package.json.js` é um gerador que escreve package.json (metadados 5.6.200 no script, distintos de 5.7.0 no JSON rastreado). Egret/4.x/scripts/modify.js reescreve o .d.ts gerado. Cocos/editor e seus entrypoints dependem de Editor/cc/Electron; os três carregadores Egret dependem do host nativo. Não executar esses efeitos durante a análise nem tratar seu suporte como implementado em Lua.\n\n';
out+='## Ferramentas Node.js (fora do runtime)\n\n'+
  'Os sete `builds/*.js` foram lidos no commit fixado e constam com classes, membros e imports no inventário.\n\n'+
  '| Arquivo | Responsabilidade e fronteira |\n| --- | --- |\n'+
  '| builds/build_base.js | Cache, cópia/download de dependências, reescrita do tsconfig e execução tsc via filesystem/processos Node. `copyDeclear` base contém `calllback` no original; registrar, sem corrigir o upstream. |\n'+
  '| builds/build_egret.js | Seleção de versão Egret 4, fontes e cópia de egret.d.ts. |\n'+
  '| builds/build_hilo.js | Seleção Hilo 1; copyDeclear retorna antes da cópia no original. |\n'+
  '| builds/build_phaser.js | Seleção Phaser 2/CE e declarações Phaser/P2/Pixi. |\n'+
  '| builds/build_pixi.js | Seleção Pixi 4 e declarações pixi-typescript. |\n'+
  '| builds/index.js | Exporta as quatro classes de build. |\n'+
  '| builds/cli.js | Parse de argumentos, validação semver e despacho para as classes. |\n\n'+
  'Não são módulos de animação. Correspondência de distribuição Lua ainda pendente; não executar downloads dinâmicos dessas ferramentas como fonte de verdade do porte.\n';
const output=path.join(__dirname,'../docs/DEPENDENCIES.md');
if (check) {if(fs.readFileSync(output,'utf8')!==out) throw Error('Dependencies report differs');}
else fs.writeFileSync(output,out);
console.log(JSON.stringify({commit:PIN,authoredTS:results.size,authoredJS:authoredJS.length,contexts:configs.length,missingInputs:unresolvedInputs.length,mode:check?'check':'generate'}));
