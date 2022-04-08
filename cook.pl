package cook_a_fish;
our $state = "have fish today\n";
sub task {
    local $state = "fish\n";
    print $state;
    buy();
    print $state;
}
sub buy {
    $state = "fish bought\n";
    wash();
}
sub wash {
    $state = "fish washed\n";
    cook();
}
sub cook {
    $state = "fish cooked\n";
}
task();
print $state;

