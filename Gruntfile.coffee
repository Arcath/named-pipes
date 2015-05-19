module.exports = (grunt) ->
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-mocha-test')

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json'),

    coffee: {
      source: {
        expand: true,
        flatten: false,
        cwd: 'src/',
        src: ['**/*.coffee'],
        dest: 'lib/',
        ext: '.js'
      }
    },

    mochaTest: {
      test: {
        options: {
          reporter: 'spec',
          require: 'coffee-script/register'
        },
        src: ['tests/*.coffee']
      }
    }

  grunt.registerTask 'test', ['coffee', 'mochaTest']
