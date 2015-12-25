gulp     = require 'gulp'
util     = require 'gulp-util'
mocha    = require 'gulp-mocha'
istanbul = require 'gulp-istanbul'
coffee   = require 'gulp-coffee'
seq      = require 'gulp-sequence'
noti     = require 'mocha-notifier-reporter'
futil    = require 'nodejs-fs-utils'
fs       = require 'fs'
deps     = require './deps'



cs    = ['lib/**/*.coffee']
js    = ["lib/**/*.js"]
tests = ['tests/**/test-*.coffee']
clean = ['coverage']

wfiles = js.concat(cs).concat(tests)


# coverVar = '$$cov_istan_vars'

watch = -> gulp.watch wfiles, (evt)->
  if evt.type is 'changed'
    deps ['./lib', './tests'], tests, ->
      gulp.src @find(evt.path), read: false
      .pipe mocha reporter: noti.decorate 'tap'
    return
  gulp.src tests, read: false
  .pipe mocha reporter: noti.decorate 'tap'

gulp.task 'mocha', (done)->
  task = gulp.src tests, read: false
  .pipe mocha reporter: noti.decorate 'tap'

# gulp.task 'istanbul', (done)->
#   gulp.src js.concat cs
#   .pipe istan includeUntested: true, coverageVariable: coverVar
#   .pipe istan.hookRequire()
#   .on 'finish', ->
#     gulp.src tests
#     .pipe mocha reporter: noti.decorate 'tap'
#     # .pipe istan.writeReports reports: ['lcov']
#     .on 'end', ->
#       console.log JSON.stringify global[coverVar]
#       # istan.summarizeCoverage()
#     # istan.writeReports()

gulp.task 'coffee', ['clean'], ->
  gulp.src ['./lib/**/*.coffee', './tests/**/test-*.coffee'], {base: './'}
    .pipe coffee bare: true
    .on 'error', util.log
    .pipe gulp.dest './dist/'

gulp.task 'pre-cover', ['coffee'], ->
  gulp.src './dist/lib/**/*.js'
    .pipe istanbul()
    .pipe istanbul.hookRequire()

gulp.task 'cover', ['pre-cover'], ->
  gulp.src './dist/tests/**/test-*.js'
    .pipe mocha()
    .pipe istanbul.writeReports()
    .pipe istanbul.enforceThresholds {thresholds: {global: 90}}


gulp.task 'clean',  -> futil.rmdirsSync dir for dir in clean when fs.existsSync dir
gulp.task 'default', seq('clean', 'mocha')
# gulp.task 'cover',   seq('clean', 'istanbul')
gulp.task 'watch', watch
gulp.task 'dev', seq('default', 'watch')
