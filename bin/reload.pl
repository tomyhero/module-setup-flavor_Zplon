#!/usr/bin/env perl

# 俺用
system('rm -rfd ~/work/Ze-Helper-Zplon/MyApp');
system('rm -rfd ~/.module-setup/flavors/Zplon');
system('module-setup --devel --pack > Ze/Helper/Zplon.pm');
system('module-setup --init --flavor-class=+Ze::Helper::Zplon Zplon');
system('module-setup MyApp Zplon');
