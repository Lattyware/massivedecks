var gulp = require('gulp-help')(require('gulp'));
var elm = require('gulp-elm');
var gutil = require('gulp-util');

var spawn = require('child_process').spawn;

gulp.task('default', 'Watches for changes while serving to a local server.', ['watch', 'serve'], function() {
});

gulp.task('make', 'Compiles all code.', ['make:elm', 'make:scala'], function() {
});

gulp.task('make:elm', 'Compiles client source code.', function() {
  return gulp
    .src('client/src/MassiveDecks.elm')
    .pipe(
      elm({filetype: 'js'})
    ).on('error', gutil.log)
    .pipe(
      gulp.dest('public/javascripts')
    )
});

gulp.task('make:scala', 'Compiles server source code.', function() {
  spawn('activator', ['compile'], {stdio: 'inherit'});
});

gulp.task('test', 'Run all tests.', ['test:scala'], function() {
  spawn('activator', ['test'], {stdio: 'inherit'});
});

gulp.task('test:scala', 'Run server tests.', function() {
  spawn('activator', ['test'], {stdio: 'inherit'});
});

gulp.task('watch', 'Compiles, then watches client code, compiling on changes.', ['make:elm'], function() {
   gulp.watch('client/src/**/*.elm', ['make:elm']);
});

gulp.task('serve', 'Run a local server, compiling server code on changes.', function(cb) {
  spawn('activator', ['~run'], {stdio: 'inherit'});
});
