// Generated on 2014-01-27 using generator-angular 0.7.1
'use strict';

// # Globbing
// for performance reasons we're only matching one level down:
// 'test/spec/{,*/}*.js'
// use this if you want to recursively match all subfolders:
// 'test/spec/**/*.js'

var dirname = (new Date()).toISOString();

module.exports = function (grunt) {

  // Load grunt tasks automatically
  require('load-grunt-tasks')(grunt);
  // Time how long tasks take. Can help when optimizing build times
  require('time-grunt')(grunt);

  // Define the configuration for all the tasks
  grunt.initConfig({

    protractor: {
      options: {
        configFile: "conf.js", // Default config file
        keepAlive: true, // If false, the grunt process stops when the test fails.
        noColor: false, // If true, protractor will not use colors in its output.
      },
      run: {}
    },
    // Project settings
    yeoman: {
      // configurable paths
      app: require('./bower.json').appPath || 'app',
      dist: 'dist'
    },

    coffee: {
      dist: {
        files: [{
          expand: true,
          cwd: 'app/scripts',
          src: ['{,*/}*.coffee'],
          dest: 'app/scripts/',
          rename: function(dest, src) {
            return dest + '/' + src.replace(/\.coffee$/, '.js');
          }
        }]
      },
      test: {
        files: [
        {
          expand: true,
          cwd: 'test/spec/controllers',
          src: ['{,*/}*.coffee'],
          dest: 'test/spec/controllers/',
          rename: function(dest, src) {
            return dest + '/' + src.replace(/\.coffee$/, '.js');
          }
        }]
      }
    },

    // Watches files for changes and runs tasks based on the changed files
    watch: {
      pro: {
        files: ['test/e2e/{,*/}*.js'],
        tasks: ['pro'],        
      },
      sass: {
          files: ['<%= yeoman.app %>/styles/{,*/}*.{scss,sass}'],
          tasks: ['sass:dist']
      },
      coffee: {
        files: ['<%= yeoman.app %>/scripts/{,*/}*.coffee','<%= yeoman.app %>/scripts/controllers/{,*/}*.coffee','test/spec/{,*/}*.coffee'],
        tasks: ['coffee:dist'],
        options: {
          livereload: true
        }
      },
      coffeetest: {
        files: ['test/spec/{,*/}*.coffee'],
        tasks: ['coffee:test'],
        options: {
          livereload: true
        }
      },

      js: {
        files: ['<%= yeoman.app %>/scripts/{,*/}*.js'],
        tasks: [], //'newer:jshint:all'
        options: {
          livereload: true
        }
      },
      jsTest: {
        files: ['test/spec/{,*/}*.js'],
        //tasks: ['karma:unit'] //'newer:jshint:test', 
      },
//      compass: {
//        files: ['<%= yeoman.app %>/styles/{,*/}*.{scss,sass}'],
//        tasks: ['compass:server', 'autoprefixer']
//      },
      gruntfile: {
        files: ['Gruntfile.js']
      },
      livereload: {
        options: {
          livereload: '<%= connect.options.livereload %>'
        },
        files: [
          '<%= yeoman.app %>/{,*/}*.html',
          '.tmp/styles/{,*/}*.css',
          '<%= yeoman.app %>/images/{,*/}*.{png,jpg,jpeg,gif,webp,svg}'
        ]
      }
    },

    sass: {
      dist: {
        options: {
                includePaths: ['<%= yeoman.app %>/bower_components'],
                outputStyle: 'compressed'
            },
            files: {
                '.tmp/styles/main.css': '<%= yeoman.app %>/sass/theme1.scss'
            }
        }
    },
    // The actual grunt server settings
    connect: {
      options: {
        port: 9000,
        // Change this to '0.0.0.0' to access the server from outside.
        hostname: 'localhost',
        livereload: 35730
      },
      livereload: {
        options: {
          open: true,
          base: [
            '.tmp',
            '<%= yeoman.app %>'
          ]
        }
      },
      test: {
        options: {
          port: 9001,
          base: [
            '.tmp',
            'test',
            '<%= yeoman.app %>'
          ]
        }
      },
      dist: {
        options: {
          base: '<%= yeoman.dist %>'
        }
      }
    },

    // Make sure code styles are up to par and there are no obvious mistakes
    jshint: {
      options: {
        jshintrc: '.jshintrc',
        reporter: require('jshint-stylish')
      },
      all: [
        'Gruntfile.js',
        '<%= yeoman.app %>/scripts/{,*/}*.js'
      ],
      test: {
        options: {
          jshintrc: 'test/.jshintrc'
        },
        src: ['test/spec/{,*/}*.js']
      }
    },

    // Empties folders to start fresh
    clean: {
      dist: {
        files: [{
          dot: true,
          src: [
            '.tmp',
            '<%= yeoman.dist %>/**/*',
            '!<%= yeoman.dist %>/.git*'
          ]
        }]
      },
      server: '.tmp'
    },

    // Add vendor prefixed styles
    autoprefixer: {
      options: {
        browsers: ['last 1 version']
      },
      dist: {
        files: [{
          expand: true,
          cwd: '.tmp/styles/',
          src: '{,*/}*.css',
          dest: '.tmp/styles/'
        }]
      }
    },

    // Automatically inject Bower components into the app
    'bower-install': {
      app: {
        html: '<%= yeoman.app %>/index.html',
        ignorePath: '<%= yeoman.app %>/'
      }
    },



    // Compiles Sass to CSS and generates necessary files if requested
    compass: {
      options: {
        sassDir: '<%= yeoman.app %>/styles',
        cssDir: '.tmp/styles',
        generatedImagesDir: '.tmp/images/generated',
        imagesDir: '<%= yeoman.app %>/images',
        javascriptsDir: '<%= yeoman.app %>/scripts',
        fontsDir: '<%= yeoman.app %>/styles/fonts',
        importPath: '<%= yeoman.app %>/bower_components',
        httpImagesPath: '/images',
        httpGeneratedImagesPath: '/images/generated',
        httpFontsPath: '/styles/fonts',
        relativeAssets: false,
        assetCacheBuster: false,
        raw: 'Sass::Script::Number.precision = 10\n'
      },
      dist: {
        options: {
          generatedImagesDir: '<%= yeoman.dist %>/images/generated'
        }
      },
      server: {
        options: {
          debugInfo: true
        }
      }
    },

    // Renames files for browser caching purposes
    rev: {
      dist: {
        files: {
          src: [
            '<%= yeoman.dist %>/scripts/{,*/}*.js',
            '<%= yeoman.dist %>/styles/{,*/}*.css',
            '<%= yeoman.dist %>/images/{,*/}*.{png,jpg,jpeg,gif,webp,svg}',
            '<%= yeoman.dist %>/styles/fonts/*'
          ]
        }
      }
    },

    // Reads HTML for usemin blocks to enable smart builds that automatically
    // concat, minify and revision files. Creates configurations in memory so
    // additional tasks can operate on them
    useminPrepare: {
      html: '<%= yeoman.app %>/index.html',
      options: {
        dest: '<%= yeoman.dist %>'
      }
    },

    // Performs rewrites based on rev and the useminPrepare configuration
    usemin: {
      html: ['<%= yeoman.dist %>/{,*/}*.html'],
      css: ['<%= yeoman.dist %>/styles/{,*/}*.css'],
      options: {
        assetsDirs: ['<%= yeoman.dist %>']
      }
    },

    // The following *-min tasks produce minified files in the dist folder
    imagemin: {
      dist: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>/images',
          src: '{,*/}*.{png,jpg,jpeg,gif}',
          dest: '<%= yeoman.dist %>/images'
        }]
      }
    },
    svgmin: {
      dist: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>/images',
          src: '{,*/}*.svg',
          dest: '<%= yeoman.dist %>/images'
        }]
      }
    },
    htmlmin: {
      dist: {
        options: {
          collapseWhitespace: true,
          collapseBooleanAttributes: true,
          removeCommentsFromCDATA: true,
          removeOptionalTags: true
        },
        files: [{
          expand: true,
          cwd: '<%= yeoman.dist %>',
          src: ['views/**/{,*/}*.html'],
          dest: '<%= yeoman.dist %>'
        }]
      }
    },

    // Allow the use of non-minsafe AngularJS files. Automatically makes it
    // minsafe compatible so Uglify does not destroy the ng references
    ngmin: {
      dist: {
        files: [{
          expand: true,
          cwd: '.tmp/concat/scripts',
          src: '*.js',
          dest: '.tmp/concat/scripts'
        }]
      }
    },

    // Replace Google CDN references
    cdnify: {
      dist: {
        html: ['<%= yeoman.dist %>/*.html']
      }
    },

    // Copies remaining files to places other tasks can use
    //            'bower_components/**/*',
    copy: {
      dist: {
        files: [{
          expand: true,
          dot: true,
          cwd: '<%= yeoman.app %>',
          dest: '<%= yeoman.dist %>',
          src: [
            '*.{ico,png,txt}',
            '.htaccess',
            '*.html',
            'views/**/{,*/}*.html',
            'images/{,*/}*.{webp}',
            'fonts/*'
          ]
        }, {
          expand: true,
          cwd: '.tmp/images',
          dest: '<%= yeoman.dist %>/images',
          src: ['generated/*']
        }, {
          expand: true,
          cwd: '<%= yeoman.app %>/others/fontello',
          dest: '<%= yeoman.dist %>/fontello',
          src: ['**/*']
        }, {
          expand: true,
          cwd: '<%= yeoman.app %>/bower_components/sass-bootstrap/fonts',
          dest: '<%= yeoman.dist %>/fonts',
          src: ['**/*']
        }, {
          expand: true,
          cwd: '<%= yeoman.app %>/others',
          dest: '<%= yeoman.dist %>/others',
          src: ['socket.io.min.js', '*.swf']
        }]
      },
      styles: {
        expand: true,
        cwd: '<%= yeoman.app %>/styles',
        dest: '.tmp/styles/',
        src: '{,*/}*.css'
      }
    },

    // Run some tasks in parallel to speed up the build process
    concurrent: {
      server: [
        'compass:server'
      ],
      test: [
        'compass'
      ],
      dist: [
        'compass:dist',
        'imagemin',
        'svgmin'
      ]
    },

    // By default, your `index.html`'s <!-- Usemin block --> will take care of
    // minification. These next options are pre-configured if you do not wish
    // to use the Usemin blocks.
     cssmin: {
       dist: {
         files: {
           '<%= yeoman.dist %>/styles/main.css': [
             '.tmp/concat/styles/{,*/}*.css'
             //,
             //'<%= yeoman.app %>/styles/{,*/}*.css'
           ]
         }
       }
     },
     uglify: {
       dist: {
         files: {
           //'<%= yeoman.dist %>/scripts/scripts.js': [
           //  '<%= yeoman.dist %>/scripts/scripts.js'
           //],
           '<%= yeoman.dist %>/scripts/scripts.js': [
             '.tmp/concat/scripts/scripts.js'
           ],
           '<%= yeoman.dist %>/scripts/vendor.js': [
             '.tmp/concat/scripts/vendor.js'
           ]
         },
         mangle: true,
         options: {
           mangle: true,
           compress: {
             sequences: true,
             dead_code: true,
             conditionals: true,
             booleans: true,
             unused: true,
             if_return: true,
             join_vars: true,
             angular: true,
             drop_console: true
           }
         }
       }

     },
     concat: {
       dist: {}
     },

    // Test settings
    karma: {
      unit: {
        configFile: 'karma.conf.js',
        singleRun: true,
        autoWatch: false
      },
      server: {
        configFile: 'karma.conf.js',
        singleRun: false,
        autoWatch: true        
      }
    },
// our shared sshconfig
    sshconfig: {
      production: {
        host: "54.76.128.148",
        port: 22,
        username: "admin",
        privateKey: grunt.file.read("/Users/iBook/.ssh/MY4TREE-KEY-PAIR.pem"),
        path: "/home/admin/4tree"
      }
    },
    // define our ssh commands
    sshexec: {
      git_pull: {
        command: ["cd /home/admin/4tree","git pull", "/etc/init.d/forever0 restart", "sleep 10"].join(' && ')
      },
      uptime: {
        command: "uptime"
      },
      start: {
        command: "cd /var/www/myapp/current && forever start -o /var/www/myapp/current/logs/forever.out -e /var/www/myapp/current/logs/forever.err --append app.js"
      },
      stop: {
        command: "forever stop app.js",
        options: {
          ignoreErrors: true
        }
      },
      'make-release-dir': {
        command: "mkdir -m 777 -p /var/www/myapp/releases/" + dirname + "/logs"
      },
      'update-symlinks': {
        command: "rm -rf /var/www/myapp/current && ln -s /var/www/myapp/releases/" + dirname + " /var/www/myapp/current"
      },
      'npm-update': {
        command: "cd /var/www/myapp/current && npm update"
      },
      'set-config': {
        command: "mv -f /var/www/myapp/current/config/<%= grunt.option('config') %>.yml /var/www/myapp/current/config/default.yml"
      }
    },
    // our sftp file copy config
    sftp: {
      deploy: {
        files: {
          "./": "dist/**"
        },
        options: {
          path: '/home/admin/4tree/dist/',
          srcBasePath: "/",
          createDirectories: true
        }
      },
      deploy_server: {
        files: {
          "./": ["server/_js/**","server/get/**","server/logJson/**","server/models/**","server/scripts/**", "server/changeset/**"]
        },
        options: {
          path: '/home/admin/4tree/server/',
          srcBasePath: "/",
          createDirectories: true,
          showProgress: true
        }
      },
      deploy_s_fast: {
        files: {
          "./": ["server/**/*.js"]
        },
        options: {
          path: '/home/admin/4tree/server/',
          srcBasePath: "/",
          createDirectories: true,
          showProgress: true
        }
      }
  },
  manifest: {
      generate: {
        options: {
          basePath: '<%= yeoman.dist %>',
          cache: [],
          network: ['http://*', 'https://*'],
          fallback: [],
          exclude: [],
          preferOnline: true,
          verbose: true,
          timestamp: true,
          hash: true,
          master: ['index.html']
        },
        src: [
          'views/**/*.html',
          'scripts/**/*.js',
          'styles/**/*.css',
          'fontello/font/*.*',
          'fonts/*.*',
          'images/**/*.*',
          'others/**/*.*'
        ],
        dest: '<%= yeoman.dist %>/manifest.appcache'
      }
    }


  });


  grunt.registerTask('serve', function (target) {
    if (target === 'dist') {
      console.info(target);
      return grunt.task.run(['build', 'connect:dist:keepalive']);
    }

    grunt.task.run([
      'clean:server',
      'bower-install',
      'concurrent:server',
      'autoprefixer',
      'connect:livereload',
      'watch'
    ]);
  });

  grunt.registerTask('server', function () {
    grunt.log.warn('The `server` task has been deprecated. Use `grunt serve` to start a server.');
    grunt.task.run(['serve']);
  });

  grunt.registerTask('pro', [
    'protractor'
  ]);

  grunt.registerTask('test', [
    'clean:server',
    'concurrent:test',
    'autoprefixer',
    'connect:test',
    'karma:unit'
  ]);

  grunt.registerTask('build', [
    'clean:dist',
    //'bower-install',
    'copy:dist',
    'useminPrepare',
    'concurrent:dist',
    'autoprefixer',
    'concat',
    'ngmin',
    //'cdnify',
    'cssmin',
    'uglify',
    'rev',
    'usemin',
    'htmlmin',
    'manifest'
  ]);

  grunt.option('config', 'production');

  grunt.registerTask('rsync', [
    'rseync'
  ])

  grunt.registerTask('build_part', [
    'clean:dist',
    //'bower-install',
    'copy:dist',
    'useminPrepare',
    'concat',
  ]);

//  grunt.registerTask('default', [
//    'newer:jshint',
//    'test',
//    'build'
//  ]);

grunt.registerTask('deploy', [
  'sshexec:git_pull'
]);

grunt.registerTask('default', ['sass', 'watch']);
grunt.loadNpmTasks('grunt-sass');
grunt.loadNpmTasks('grunt-contrib-watch');
grunt.loadNpmTasks('grunt-contrib-coffee');
grunt.loadNpmTasks('grunt-protractor-runner');
grunt.loadNpmTasks('grunt-manifest');
grunt.loadNpmTasks('grunt-ssh');

};
