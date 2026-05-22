const vscode = require('vscode');
const fs = require('fs');
const path = require('path');
const os = require('os');

function getClaudeDir() {
  const configured = vscode.workspace.getConfiguration('glmToggle').get('claudeDir');
  return configured && configured.trim() ? configured : path.join(os.homedir(), '.claude');
}

function paths() {
  const dir = getClaudeDir();
  return {
    settings: path.join(dir, 'settings.json'),
    glmProfile: path.join(dir, 'profiles', 'glm.json'),
    claudeProfile: path.join(dir, 'profiles', 'claude.json'),
  };
}

function getCurrentMode() {
  const { settings } = paths();
  try {
    const content = fs.readFileSync(settings, 'utf8');
    return content.includes('api.z.ai') ? 'glm' : 'claude';
  } catch (e) {
    return 'unknown';
  }
}

let statusBarItem;
let watcher;
let treeProvider;

function updateStatusBar() {
  if (!statusBarItem) return;
  const mode = getCurrentMode();
  if (mode === 'glm') {
    statusBarItem.text = '$(zap) GLM-5.1';
    statusBarItem.tooltip = 'Claude Code: GLM-5.1 (z.ai)\nClick to switch to native Claude.\nRestart Claude Code after switching.';
    statusBarItem.backgroundColor = new vscode.ThemeColor('statusBarItem.warningBackground');
  } else if (mode === 'claude') {
    statusBarItem.text = '$(sparkle) Claude';
    statusBarItem.tooltip = 'Claude Code: Native Claude\nClick to switch to GLM-5.1.\nRestart Claude Code after switching.';
    statusBarItem.backgroundColor = undefined;
  } else {
    statusBarItem.text = '$(warning) GLM?';
    statusBarItem.tooltip = 'GLM Toggle: settings.json not found at ' + paths().settings;
    statusBarItem.backgroundColor = new vscode.ThemeColor('statusBarItem.errorBackground');
  }
}

function refreshAll() {
  updateStatusBar();
  if (treeProvider) treeProvider.refresh();
}

function setMode(targetMode) {
  const p = paths();
  const source = targetMode === 'glm' ? p.glmProfile : p.claudeProfile;
  if (!fs.existsSync(source)) {
    vscode.window.showErrorMessage(`GLM Toggle: profile not found: ${source}`);
    return;
  }
  try {
    fs.copyFileSync(source, p.settings);
    refreshAll();
    const label = targetMode === 'glm' ? 'GLM-5.1 (z.ai)' : 'Native Claude';
    vscode.window.showInformationMessage(`Switched to ${label}. Restart Claude Code to apply.`);
  } catch (e) {
    vscode.window.showErrorMessage(`GLM Toggle: failed to switch — ${e.message}`);
  }
}

function setupWatcher(context) {
  try {
    if (watcher) {
      watcher.close();
      watcher = null;
    }
    const { settings } = paths();
    if (fs.existsSync(settings)) {
      watcher = fs.watch(settings, { persistent: false }, () => {
        setTimeout(refreshAll, 100);
      });
      context.subscriptions.push({ dispose: () => watcher && watcher.close() });
    }
  } catch (e) {
    // settings.json may not exist yet; watcher will be retried after config change
  }
}

class GlmToggleTreeProvider {
  constructor() {
    this._onDidChangeTreeData = new vscode.EventEmitter();
    this.onDidChangeTreeData = this._onDidChangeTreeData.event;
  }
  refresh() {
    this._onDidChangeTreeData.fire();
  }
  getTreeItem(element) {
    return element;
  }
  getChildren() {
    const mode = getCurrentMode();
    const isGlm = mode === 'glm';
    const isClaude = mode === 'claude';

    const items = [];

    const header = new vscode.TreeItem(
      isGlm ? 'Current: GLM-5.1' : isClaude ? 'Current: Native Claude' : 'Current: Unknown',
      vscode.TreeItemCollapsibleState.None
    );
    header.description = isGlm ? '(z.ai)' : isClaude ? '(Anthropic)' : '(settings.json missing)';
    header.iconPath = new vscode.ThemeIcon(
      isGlm ? 'zap' : isClaude ? 'sparkle' : 'warning',
      new vscode.ThemeColor(isGlm ? 'charts.yellow' : isClaude ? 'charts.blue' : 'charts.red')
    );
    header.tooltip = 'Active Claude Code mode';
    items.push(header);

    const sep1 = new vscode.TreeItem(' ', vscode.TreeItemCollapsibleState.None);
    sep1.description = '─────────────';
    items.push(sep1);

    const switchToGlm = new vscode.TreeItem(
      isGlm ? 'GLM-5.1 (active)' : 'Switch to GLM-5.1',
      vscode.TreeItemCollapsibleState.None
    );
    switchToGlm.description = isGlm ? '✓' : 'via z.ai';
    switchToGlm.iconPath = new vscode.ThemeIcon('zap', new vscode.ThemeColor('charts.yellow'));
    switchToGlm.tooltip = isGlm
      ? 'Already in GLM-5.1 mode'
      : 'Click to switch to GLM-5.1 (z.ai)';
    if (!isGlm) {
      switchToGlm.command = { command: 'glmToggle.on', title: 'Enable GLM' };
    }
    items.push(switchToGlm);

    const switchToClaude = new vscode.TreeItem(
      isClaude ? 'Native Claude (active)' : 'Switch to Native Claude',
      vscode.TreeItemCollapsibleState.None
    );
    switchToClaude.description = isClaude ? '✓' : 'Anthropic API';
    switchToClaude.iconPath = new vscode.ThemeIcon('sparkle', new vscode.ThemeColor('charts.blue'));
    switchToClaude.tooltip = isClaude
      ? 'Already in Native Claude mode'
      : 'Click to switch to Native Claude';
    if (!isClaude) {
      switchToClaude.command = { command: 'glmToggle.off', title: 'Disable GLM' };
    }
    items.push(switchToClaude);

    const sep2 = new vscode.TreeItem(' ', vscode.TreeItemCollapsibleState.None);
    sep2.description = '─────────────';
    items.push(sep2);

    const toggleItem = new vscode.TreeItem('Toggle (flip current mode)', vscode.TreeItemCollapsibleState.None);
    toggleItem.iconPath = new vscode.ThemeIcon('arrow-swap');
    toggleItem.tooltip = 'Switch to the opposite mode';
    toggleItem.command = { command: 'glmToggle.toggle', title: 'Toggle' };
    items.push(toggleItem);

    const sep3 = new vscode.TreeItem(' ', vscode.TreeItemCollapsibleState.None);
    sep3.description = '─────────────';
    items.push(sep3);

    const restartHint = new vscode.TreeItem('Mode changed?', vscode.TreeItemCollapsibleState.None);
    restartHint.description = 'Restart Claude Code';
    restartHint.iconPath = new vscode.ThemeIcon('info', new vscode.ThemeColor('charts.orange'));
    restartHint.tooltip = 'Env vars are only read at Claude Code startup. Restart Claude Code for the change to take effect.';
    items.push(restartHint);

    return items;
  }
}

function activate(context) {
  statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 100);
  statusBarItem.command = 'glmToggle.toggle';
  statusBarItem.show();
  updateStatusBar();
  context.subscriptions.push(statusBarItem);

  treeProvider = new GlmToggleTreeProvider();
  context.subscriptions.push(
    vscode.window.registerTreeDataProvider('glmToggleView', treeProvider)
  );

  context.subscriptions.push(
    vscode.commands.registerCommand('glmToggle.toggle', () => {
      const mode = getCurrentMode();
      if (mode === 'unknown') {
        vscode.window.showErrorMessage('GLM Toggle: cannot determine current mode (settings.json missing).');
        return;
      }
      setMode(mode === 'glm' ? 'claude' : 'glm');
    }),
    vscode.commands.registerCommand('glmToggle.on', () => setMode('glm')),
    vscode.commands.registerCommand('glmToggle.off', () => setMode('claude')),
    vscode.commands.registerCommand('glmToggle.status', () => {
      const mode = getCurrentMode();
      const label = mode === 'glm' ? 'GLM-5.1 (z.ai)' : mode === 'claude' ? 'Native Claude' : 'Unknown';
      vscode.window.showInformationMessage(`Current mode: ${label}`);
    }),
    vscode.commands.registerCommand('glmToggle.refresh', () => refreshAll())
  );

  context.subscriptions.push(
    vscode.workspace.onDidChangeConfiguration((e) => {
      if (e.affectsConfiguration('glmToggle')) {
        refreshAll();
        setupWatcher(context);
      }
    })
  );

  setupWatcher(context);
}

function deactivate() {
  if (watcher) watcher.close();
}

module.exports = { activate, deactivate };
