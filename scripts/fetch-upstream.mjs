import { spawnSync } from 'node:child_process';
import { existsSync, mkdirSync, rmSync } from 'node:fs';
import { resolve } from 'node:path';
import { UPSTREAM } from '../upstream.lock.mjs';

const root = resolve('vendor');
const destination = resolve(root, 'DragonBonesJS');
const run = (args, cwd) => {
  const p = spawnSync('git', args, { cwd, encoding: 'utf8' });
  if (p.error || p.status !== 0) {
    throw new Error(p.error?.message ?? p.stderr?.trim() ?? 'Falha no git');
  }
  return p.stdout.trim();
};
try {
  if (existsSync(destination)) {
    const revision = run(['-C', destination, 'rev-parse', 'HEAD']);
    if (revision !== UPSTREAM.commit) {
      throw new Error('A cópia local não corresponde ao commit fixado. Remova-a manualmente após salvar seus trabalhos.');
    }
    console.log('Código original já instalado e verificado:', revision);
    process.exit(0);
  }
  mkdirSync(root, { recursive: true });
  run(['clone', '--no-checkout', UPSTREAM.repository, destination]);
  run(['-C', destination, 'checkout', '--detach', UPSTREAM.commit]);
  console.log('Código original fixado em', UPSTREAM.commit);
} catch (error) {
  // Preserve an existing directory; do not delete user changes.
  console.error(error.message);
  process.exitCode = 1;
}
