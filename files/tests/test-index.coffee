{expect: e} = require 'chai'
idx = require '../lib/index'

describe 'index', ->
  it 'a', ->
    e(idx.a 1).to.be.equal 2
