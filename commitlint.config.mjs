import { execSync } from 'child_process';

const BTF_ISSUE_REGEX = /(BTF\-\d{1,10})(?=\-|$)/;
const DEFAULT_ISSUE_REGEX = /(\d{3,})/;

const ALL_REGEX = [BTF_ISSUE_REGEX, DEFAULT_ISSUE_REGEX];
const COMMIT_AMOUNT_FOR_SCOPES = 20

const branch = execSync('git rev-parse --abbrev-ref HEAD').toString().trim();
const issue = ALL_REGEX
  .map(regex => branch.match(regex)?.[0])
  .find(match => match) || null;

const angular_projects = execSync("ng config projects | jq -r 'keys[]'").toString().trim()
  .split('\n')
  .filter(pkg => !pkg.startsWith('No config found.'))

const maven_projects = execSync(`awk -F'[<>]' '/<module>/{print $3}' "$(git rev-parse --show-toplevel)/pom.xml" 2>/dev/null || true`).toString().trim().split('\n')

let last_used_scopes = execSync(`git log -${COMMIT_AMOUNT_FOR_SCOPES} --pretty=%B | sed -nE "s/^[a-z]+\\(([^)]+)\\):.*/\\1/p"`).toString().trim();
last_used_scopes = last_used_scopes.split("\n")
const last_used_scope = last_used_scopes[0] ?? "" 


const default_scopes = ['frontend', 'backend', 'db'];
let scopes = [];
scopes = scopes.concat(default_scopes);
scopes = scopes.concat(angular_projects);
scopes = scopes.concat(maven_projects);
scopes = scopes.concat(last_used_scopes);

scopes = [...new Set(scopes)]

/** @type {import('cz-git').UserConfig} */
const config = {
  prompt: {
    customIssuePrefixAlign: !issue ? "top" : "bottom",
    customScopesAlign: "top",
    defaultIssues: !issue ? "" : `#${issue}`,
    skipQuestions: ['body','breaking','confirmCommit'],
    formatMessageCB: (message) => message.defaultMessage.replace(/\n/g, " "),
    scopes: scopes,
    issuePrefixes: [
      { value: '', name: 'link:   links to ISSUE' },
      { value: 'closed', name: 'closed:   ISSUES has been processed' }
    ],
    defaultScope: last_used_scope,
  },
  alias: {
    "fd": "docs: fix typos",
    "ur": "docs: update README",
    ":": "docs(blog): update posts",
    "cl": "style: clean up",
    "b": "chore: run pipeline"
  }
};

export default config;
