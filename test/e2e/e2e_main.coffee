By = protractor.By
ptor = protractor.getInstance();
#ptor.ignoreSynchronization = true;

describe "angularjs homepage!!!", ->
  it "should greet the named user", ->
    browser.get "http://localhost:8888/"
    element(By.model("myname")).clear();
    element(By.model("myname")).sendKeys "Julie"
    greeting = element(By.binding("myname"))
    expect(greeting.getText()).toEqual "Julie"

describe "A suite", ->
  it "contains spec with an expectation", ->
    browser.get "http://localhost:8888/"
    element(By.model("myname")).clear();
    element(By.model("myname")).sendKeys "John"
    greeting = element(By.binding("myname"))
    expect(greeting.getText()).toEqual "John"    
