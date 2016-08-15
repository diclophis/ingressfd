#

controller = IngressFd::Controller.new(:run_loop => $run_loop)
controller.ingress

$stdout.write("init")
$run_loop.run
