// Karma configuration
// http://karma-runner.github.io/0.10/config/configuration-file.html

module.exports = function(config) {
  config.set({
    // base path, that will be used to resolve files and exclude
    basePath: '',

    // testing framework to use (jasmine/mocha/qunit/...)
    frameworks: ['jasmine'],

    preprocessors: {
      'app/**/*.html': ['ng-html2js'],
      'app/scripts/**/*.js': ['coverage']
    },

    ngHtml2JsPreprocessor: {
      moduleName: 'templates'
    },

    // list of files / patterns to load in the browser
    files: [
      'app/bower_components/jquery/dist/jquery.js',
      'app/bower_components/angular/angular.js',
      'app/bower_components/angular-mocks/angular-mocks.js',
      'app/bower_components/angular-resource/angular-resource.js',
      'app/bower_components/angular-cookies/angular-cookies.js',
      'app/bower_components/angular-sanitize/angular-sanitize.js',
      'app/bower_components/angular-route/angular-route.js',
      'app/bower_components/angular-translate/angular-translate.js',
      'app/bower_components/nanoscroller/bin/javascripts/jquery.nanoscroller.js',
      'app/bower_components/angular-nanoscroller/scrollable.js',
      'app/bower_components/angular-animate/angular-animate.js',
      'app/bower_components/angular-redactor/angular-redactor.js',
      'app/bower_components/CryptoJS-v3.1.2-2/rollups/sha3.js',
      'app/bower_components/CryptoJS-v3.1.2-2/rollups/aes.js',
      'app/bower_components/CryptoJS-v3.1.2-2/rollups/rabbit.js',
      'app/bower_components/CryptoJS-v3.1.2-2/rollups/rc4.js',
      'app/bower_components/CryptoJS-v3.1.2-2/rollups/tripledes.js',
      'app/bower_components/momentjs/moment.js',
      "app/bower_components/angular-strap/dist/angular-strap.js",
      "app/bower_components/sass-bootstrap/dist/js/bootstrap.js",
      "app/bower_components/ng-bs-daterangepicker/src/ng-bs-daterangepicker.js",
      "app/bower_components/ng-tags-input/ng-tags-input.js",
      "app/bower_components/ng-clip-master/dest/ng-clip.js",
      "app/bower_components/zeroclipboard/ZeroClipboard.js",
      'app/bower_components/underscore/underscore.js',
      'others/mongo-objectid.js',
      'app/bower_components/angular-virtual-scroll/angular-virtual-scroll.js',
      "app/bower_components/angular-range-slider/angular.rangeSlider.js",
      "app/others/lodash.underscore.js",
      'app/*.html',
      'app/scripts/**/*.js',
      'app/others/**/*.js',
      'tests/unit/**/*.js',
      'tests/mock/**/*.js',
      'tests/spec/**/*.js',
      'app/scripts/_js/app.js'
    ],

    // list of files / patterns to exclude
    exclude: [],

    // web server port
    port: 8080,

    // level of logging
    // possible values: LOG_DISABLE || LOG_ERROR || LOG_WARN || LOG_INFO || LOG_DEBUG
    logLevel: config.LOG_INFO,


    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: false,


    // Start these browsers, currently available:
    // - Chrome
    // - ChromeCanary
    // - Firefox
    // - Opera
    // - Safari (only Mac)
    // - PhantomJS
    // - IE (only Windows)
    browsers: ['PhantomJS'],


    // Continuous Integration mode
    // if true, it capture browsers, run tests and exit
    singleRun: false
  });
};
