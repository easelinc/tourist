module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    concat: {
      dist: {
        src: ['src/**/*.coffee'],
        dest: '<%= pkg.name %>.coffee'
      }
    },

    coffee: {
      build: {
        files: {
          '<%= pkg.name %>.js': '<%= pkg.name %>.coffee',
        }
      },
      test: {
        expand: true,
        cwd: 'test/src/',
        src: ['**/*.coffee'],
        dest: 'test/lib/',
        ext: '.js'
      }
    },

    uglify: {
      options: {
        banner: '/*! Tourist.js - http://easelinc.github.io/tourist, built <%= grunt.template.today("mm-dd-yyyy") %> */\n'
      },
      dist: {
        files: {
          '<%= pkg.name %>.min.js': ['<%= pkg.name %>.js']
        }
      }
    },

    watch: {
      build: {
        files: ['src/**/*.coffee'],
        tasks: ['concat', 'coffee:build']
      },
      test: {
        files: ['test/src/**/*.coffee'],
        tasks: ['coffee:test']
      }
    },

    jasmine: {
      src: '<%= pkg.name %>.js',
      options: {
        specs: ['test/lib/tourSpec.js', 'test/lib/tip/baseSpec.js', 'test/lib/tip/qtipSpec.js', 'test/lib/tip/bootstrapSpec.js'],
        helpers: 'test/lib/**/*Helper.js',
        vendor: ['test/vendor/javascripts/jquery-1.9.1.js',
          'test/vendor/javascripts/underscore-1.4.4.js',
          'test/vendor/javascripts/backbone-1.0.0.js',
          'test/vendor/javascripts/jquery.qtip.js',
          'test/vendor/javascripts/jquery-ui-1.10.2.custom.js',
          'test/vendor/javascripts/jasmine-jquery.js'
        ]
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-jasmine');

  grunt.registerTask('test', ['concat', 'coffee', 'jasmine']);
  grunt.registerTask('default', ['concat', 'coffee', 'uglify']);
};
