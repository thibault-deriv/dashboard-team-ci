#!/usr/bin/env perl

# Quick and dirty
# Use like this :
# cat modules | ./gen.pl > README.md

my $startyml = << "END";
on:
  push:
  schedule:
    - cron: 0 12 * * *

jobs:
  perl:

    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout\@v2
      - name: perl -V
        run: perl -V
END

my $endyml = << "END";
      - name: Install module
END


my @badges = ();

print "| :camel: | :camel: | :camel: | :camel: | :camel: |\n";
print "|  :---:  |  :---:  |  :---:  |  :---:  |  :---:  |\n";
my $cells = 0;

while(<>) {
	my $line = $_;
	chomp $line;

	# Debian deps (if any) are listed after a space
	my ($full_module, @debs) = split(" ", $line);

	# Prepare filename with dashes for GitHub
	my @all = split("::", $full_module);
	my $module = join "-", @all;

	my $filename = ".github/workflows/$module.yml";
	open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
	print $fh "name : $module\n\n";
	print $fh $startyml;

	if(@debs) {
		print $fh "      - name: apt-get update\n";
		print $fh "        run: sudo apt-get update\n";
		print $fh "      - name: Install non alienazed dependencies\n";
		print $fh "        run: sudo apt-get install @debs\n";
	}
	print $fh $endyml;
	print $fh "        run: curl -L https://cpanmin.us | perl - --configure-timeout=1920 ";
	print "| [![$module](https://github.com/thibault-deriv/dashboard-team-ci/workflows/$module/badge.svg)](https://github.com/thibault-deriv/dashboard-team-ci/actions?query=workflow%3A$module) ";
	$cells ++;

	if($cells >= 5) { 
		$cells = 0;
		print "|\n";
	}
	print $fh "$full_module\n";
	close $fh;
}

print "|" if($cells);
print "\n\n";
