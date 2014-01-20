/*global module:false*/
module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    // Task configuration.
    jshint: {
      options: {
        curly: true,
        eqeqeq: true,
        immed: true,
        latedef: true,
        newcap: true,
        noarg: true,
        sub: true,
        undef: true,
        unused: true,
        boss: true,
        eqnull: true,
        browser: true,
        globals: {
          jQuery: true,
          "$": true,
          _: true,
          ST: true,
          Bacon: true
        }
      },
      gruntfile: {
        src: 'Gruntfile.js'
      },
      src: {
        src: [
          'app/assets/javascripts/**/*.js',
          '!app/assets/javascripts/application.js',
          '!app/assets/javascripts/dashboard.js',
          '!app/assets/javascripts/fastclick.min.js',
          '!app/assets/javascripts/googlemaps.js',
          '!app/assets/javascripts/homepage.js',
          '!app/assets/javascripts/kassi.js',
          '!app/assets/javascripts/kassi_dashboard.js',
          '!app/assets/javascripts/map_label.js',
          '!app/assets/javascripts/markerclusterer.js',
          '!app/assets/javascripts/mercury.js',
          '!app/assets/javascripts/sharetribe_common.js'
          ]
      }
    },
    mochaTest: {
      test: {
        options: {
          reporter: 'spec',
          require: './app/assets/javascripts/test/node_globals.js'
        },
        src: ['app/assets/javascripts/test/**/*.js']
      }
    },
    watch: {
      // Nothing here
    }
  });

  // These plugins provide necessary tasks.
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-mocha-test');

  // Default task.
  grunt.registerTask('default', ['jshint', 'mochaTest']);

};
