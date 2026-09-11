'use client';

import { XDecryptedText } from '@xscriptor/xcomponents';

const REPOS = [
  'xlnux/x',
  'xlnux/wsl',
  'xlnux/wiki',
  'xlnux/wsl-scripts',
  'xlnux/scripts',
  'xlnux/xpm',
  'xlnux/xpkg',
  'xlnux/web',
  'xlnux/x-repo',
];

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center gap-14 px-6 py-16 text-center">
      <div className="space-y-10">
        <a
          href="https://github.com/xlnux"
          target="_blank"
          rel="noreferrer"
          className="text-sm tracking-[0.3em] text-X-gray transition-colors hover:text-X-cyan"
        >
          GITHUB.COM/XLNUX
        </a>
        <ul className="space-y-4">
          {REPOS.map((repo) => (
            <li key={repo}>
              <a
                href={`https://github.com/${repo}`}
                target="_blank"
                rel="noreferrer"
                className="text-2xl font-bold text-X-white transition-colors hover:text-X-cyan sm:text-3xl"
              >
                <XDecryptedText
                  text={repo}
                  speed={40}
                  sequential
                  revealDirection="start"
                  animateOn="view"
                  encryptedClassName="text-X-purple"
                />
              </a>
            </li>
          ))}
        </ul>
      </div>

      <p className="max-w-xl text-sm leading-relaxed text-X-gray">
        x-repo is the dedicated repository for serving artifacts for X Linux. It hosts
        the prebuilt packages and metadata for the <span className="text-X-cyan">[x]</span>{' '}
        pacman repository and the native <span className="text-X-cyan">.xp</span> endpoint
        used by xpm, together with the source recipes used to build them. Packages are
        built locally and committed here; this site only publishes them.
      </p>
    </main>
  );
}
