describe 'CryptJS testing', ()->
  app = null
  $rootScope = null
  $compile = null
  cryptApi = null
  beforeEach ->
    app = angular.mock.module('4treeApp', [])
  beforeEach ->
    inject (_$compile_, _$rootScope_)->
      $compile = _$compile_;
      $rootScope = _$rootScope_;


  it 'should be registered', ()->
    console.info 'app = ', app
    expect(module).not.toBe(null)

  it 'try to compile html', ()->
    $rootScope.hello = 'Hello!!!'
    $rootScope.test = 'Test'
    element = $compile("<b>{{hello}} - {{test}}</b>")($rootScope)
    $rootScope.$digest();
    expect(element.html()).toContain("Hello!!!")
    expect(element.html()).toContain("Test")
  ###
  it 'should contain service cryptApi',
    inject ['$translate', ($translate) ->
      expect($translate).not.toBe(null)
    ]
  ###

  it 'all ok', ()->
    a = true;
    expect(true).toBe true
