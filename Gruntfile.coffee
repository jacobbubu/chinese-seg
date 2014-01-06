module.exports = (grunt) ->
  grunt.config.init
    pkg: grunt.file.readJSON('package.json')
    clean:
      lib:
        src: [ './lib/**' ]
    coffee:
      src:
        options:
          bare: true
          sourceMap: false
          join: false
        files: [
          {
            expand: true
            ext: '.js'
            cwd: './src'
            src: './**/*.coffee'
            dest: './lib'
          }
        ]

  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'

  grunt.registerTask 'default',  ['clean:lib', 'coffee:src']