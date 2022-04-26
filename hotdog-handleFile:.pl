#!/usr/bin/perl

use File::Type;
use File::Basename;

$path = shift @ARGV;
if (not $path) {
    die('specify file');
}

# figure out what it is...
my $ft = File::Type->new();

# alternatively, check file from disk
my $type_from_file = $ft->checktype_filename($path);

if ($type_from_file eq 'application/x-executable-file') {
  # should we launch exes?
  system('hotdog', 'alert', "Should we execute application files '$path'?? - type '$type_from_file'");
  exit(0);
}

# images can be detected
if (index($type_from_file,'image/') == 0) {
  my $img = 'eog';
  system($img, $path);
  exit(0);
}

# text files are just octet streams... not useful. Check extension?

if ($type_from_file eq 'application/octet-stream') {
  my @txts = qw(\.txt \.conf \.cfg \.bat \.sh);
  my $txt = 'gedit';

  my @medias = qw(\.mp3 \.wav \.mp4 \.mpg \.mov \.wmv \.mkv \.webm);
  my $media='vlc';

  my ($name, $dir, $ext) = fileparse($path, @txts);
  if (not $ext eq "") {
    system($txt, $path);
    exit(0);
  }

  my ($name, $dir, $ext) = fileparse($path, @medias);
  if (not $ext eq "") {
    system($media, $path);
    exit(0);
  }

  system('hotdog', 'alert', "Unknown extension on '$path' - type '$type_from_file'");
  exit(0);
}

system('hotdog', 'alert', "Unknown file type '$path' - type '$type_from_file'");

