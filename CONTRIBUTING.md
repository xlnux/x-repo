<h1 align="center"> Contributing to X Repo </h1>

<div align="center">
  <p>Thank you for considering contributing! This repository is the heart of the X Linux web presence and system identity. Please follow these guidelines to help us maintain a professional and efficient ecosystem.</p>
</div>

<hr />

<h2 align="center"> Table of Contents </h2>
<p align="center">
  <a href="#how-to-contribute">How to Contribute</a> •
  <a href="#project-structure">Project Structure</a> •
  <a href="#development-rules">Development Rules</a>
</p>

<hr />

<h2 align="center" id="how-to-contribute"> How to Contribute </h2>

<ol>
  <li><b>Fork</b> the repository to your own GitHub account.</li>
  <li><b>Create a branch</b> for your specific task (<code>git checkout -b feat/new-docs-section</code> or <code>git checkout -b fix/x-release-branding</code>).</li>
  <li><b>Commit</b> your changes. For web updates, ensure the build passes locally. For packages, verify the <code>XBUILD</code> logic.</li>
  <li><b>Push</b> to your branch and open a <b>Pull Request</b> against the main branch.</li>
</ol>

<h2 align="center" id="project-structure"> Project Structure </h2>

<ul>
  <li><b>Website (root/app)</b>: Next.js 16 source code. Changes here affect the official X Linux site.</li>
  <li><b>Packages (packages/)</b>: Core system files like <code>x-release</code>. Essential for the OS identity.</li>
  <li><b>Repository Tools</b>: <code>build-packages.sh</code> builds the packages and regenerates the pacman-compatible database.</li>
</ul>

<h2 align="center" id="development-rules"> Development Rules </h2>

<h3 align="center"> Web Development </h3>
<ul>
  <li>Maintain the visual style using <b>Tailwind CSS 4</b> and the X palette defined in <code>app/globals.css</code>.</li>
  <li>Ensure all new components are responsive and support both light and dark themes.</li>
  <li>Keep the page lightweight: no 3D scenes or heavy animation libraries.</li>
</ul>

<h3 align="center"> System Packaging </h3>
<ul>
  <li>When modifying <code>x-release</code>, ensure branding templates remain compatible with standard Arch paths.</li>
  <li>Use <b>xpkg</b> and <b>xpm</b> for native package testing before submitting a PR.</li>
  <li>Do not modify the repository database manually; use the provided build scripts.</li>
</ul>

<h3 align="center"> General </h3>
<ul>
  <li>Respect the <b>Code of Conduct</b> at all times.</li>
  <li>For security vulnerabilities, please refer directly to our <a href="SECURITY.md"><b>SECURITY.md</b></a>.</li>
</ul>

<hr />

<div align="center">
  <p><i>By contributing, you agree that your code will be licensed under the <b>GPL v3.0</b> for system files and the respective project licenses for web tools.</i></p>
  <p><b>Thank you for building the future of X Linux with us!</b></p>
</div>