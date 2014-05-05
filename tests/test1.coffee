# Мой первый тест в Шторме
should = require('should')
assert = require('assert')

describe 'test of mine', ()->
  it 'all ok', ()->
    true.should.eql(true)
  it 'all ok number 2', ()->
    true.should.eql(true)


describe 'Async test', ()->
  result = false;

  beforeEach (done)->

    setTimeout ()->
      result = true
      done();
    , 5000

  it "Do it in 2000", (done)->
    result.should.eql (true);
    done();