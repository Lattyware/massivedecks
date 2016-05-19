var gulp = require('gulp');
var elm = require('gulp-elm');
var gutil = require('gulp-util');

gulp.task('default', ['make'], function() {
});

gulp.task('make', function() {
  return gulp
    .src('client/src/MassiveDecks.elm')
    .pipe(
      elm({filetype: 'js'})
    ).on('error', gutil.log)
    .pipe(
      gulp.dest('public/javascripts')
    )
});

gulp.task('watch', ['make'], function () {
   gulp.watch('client/src/**/*.elm', ['make']);
});
