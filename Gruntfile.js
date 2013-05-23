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
        flatten: true,
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
        tasks: ['coffee:build']
      },
      test: {
        files: ['test/src/**/*.coffee'],
        tasks: ['coffee:test']
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-watch');

  grunt.registerTask('default', ['concat', 'coffee', 'uglify']);
};
