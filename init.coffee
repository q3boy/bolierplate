#!/usr/bin/env coffee
path   = require 'path'
fs     = require 'fs'
futil = require 'nodejs-fs-utils'
cp     = require 'child_process'
rl     = require 'readline-sync'
chalk  = require 'chalk'

dir = process.cwd()

name = rl.question "name: [#{chalk.underline.green name = path.basename process.cwd()}] "
  , defaultInput: name, limit : /^[a-z][\w\-]*$/i
version = rl.question "version: [#{chalk.underline.green version = '0.1.0'}] "
  , defaultInput: version, limit : /^\d+(\.\d+){2,3}$/i
description = rl.question "description: [#{chalk.underline.green name}] ", defaultInput: name

keywords = []
for keyword in rl.question("keywords (split with ,): ", defaultInput: '').split ','
  continue if '' is keyword = keyword.trim()
  keywords.push keyword

switch (repoType = rl.question "repo type: [#{chalk.underline.green 'github'}] "
    , limit: ['github', 'gitlab'], defaultInput: 'github')
  when 'github'
    repo     = "https://q3boy@github.com/q3boy/#{name}.git"
    homepage = "http://github.com/q3boy/#{name}"
    bugs     = url : "http://github.com/q3boy/#{name}/issues"
    author   = "q3boy <q3boy1@gmail.com>"
    gitUser  = 'q3boy'
    gitEmail = 'q3boy1@gmail.com'
  when 'gitlab'
    repoGroup = rl.question 'gitlab group: ', limit : /^[a-z][\w\-]*$/i
    repo      = "git@gitlab.alibaba-inc.com:#{repoGroup}/#{name}.git"
    homepage  = "http://http://gitlab.alibaba-inc.com/#{repoGroup}/#{name}"
    bugs      = url : "http://http://gitlab.alibaba-inc.com/#{repoGroup}/#{name}/issues"
    author    = "清笃 <qingdu@alibaba-inc.com>"
    gitUser   = '清笃'
    gitEmail  = 'qingdu@taobao.com'
  else
    throw new Error "Repo type error '#{repoType}'."

package_json =
  name            : name
  version         : version
  description     : description
  main            : 'index.js'
  directories     : test : "tests"
  scripts         : test : "gulp test"
  repository      : type : 'git', url : repo
  keywords        : keywords
  author          : author
  license         : "ISC"
  dependencies    : {}
  devDependencies :
    "coffee-script"           : "^1.10.0"
    "mocha"                   : "^2.4.5"
    "istanbul"                : "^0.4.1"
    "chai"                    : "^3.5.0"
    "sinon"                   : "^1.17.2"
    "sinon-chai"              : "^2.8.0"
    "gulp"                    : "^3.9.1"
    "gulp-util"               : "^3.0.7"
    "gulp-sequence"           : "^0.4.5"
    "gulp-coffee"             : "^2.3.1"
    "gulp-mocha"              : "^2.2.0"
    "mocha-notifier-reporter" : "^0.1.1"
    "gulp-istanbul"           : "^0.10.3"
    "madge"                   : "^0.5.3"
    "glob-stream"             : "^5.3.1"
    "nodejs-fs-utils"         : "^1.0.26"

fs.writeFileSync 'package.json', JSON.stringify package_json, null, 2
console.log chalk.bold.green('[ok]'), 'package.json'

sublime_json =
  folders: [
    {path : dir, folder_exclude_patterns: ["coverage", "report", "dist"], file_exclude_patterns: [".zip", "*.sublime-*"]}
  ]
  syntax_override : {"test-\\w+\\.coffee$": ["Mocha Chai CoffeeScript", "Syntaxes", "Mocha Chai CoffeeScript"]}

fs.writeFileSync "#{name}.sublime-project", JSON.stringify sublime_json, null, 2
console.log chalk.bold.green('[ok]'), "#{name}.sublime-project"

ignores = ['n,ode_modules', 'coverage', 'dist', '.DS_Store''*.sublime*']

fs.writeFileSync ".gitignore", ignores.join '\n'
console.log chalk.bold.green('[ok]'), ".gitignore"

ignores = ['node_modules', '/coverage', '/dist/tests', '/tests', "/build", "/gulpfile.js", '.DS_Store', '*.sublime*']
fs.writeFileSync ".npmignore", ignores.join '\n'
console.log chalk.bold.green('[ok]'), ".npmignore"

fs.writeFileSync 'README.md', "#{name}\n===\n\n#{description}\n"
console.log chalk.bold.green('[ok]'), "README.md"

cmds = [
  'git init'
  "git config user.name \"#{gitUser}\""
  "git config user.email \"#{gitEmail}\""
  "git config remote.origin.url \"#{package_json.repository.url}\""
  "git add .gitignore README.md"
  "git commit -m 'first-commit'"
]

for cmd in cmds
  [cmd, args...] = cmd.split ' '
  throw ret.error unless 0 is cp.spawnSync(cmd, args).status

console.log chalk.bold.green('[ok]'), "git init"


srcdir = path.join fs.realpathSync(__dirname), 'files'
futil.copySync srcdir, dir, (err) ->
  throw err if err
# for file in fs.readdirSync srcdir
#   # console.log path.join(srcdir, file), path.join dir, file
#   futil.copySync path.join(srcdir, file), dir, (err) ->
#     throw err if err

console.log chalk.bold.green('[ok]'), "files copy"


