$run_loop = UV.default_loop

$stdout = UV::TTY.new(1, 1)
$stdout.set_mode(0)
$stdout.reset_mode

$stdout.write("globals")
