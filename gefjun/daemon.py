from pid import PidFile
from daemoniker import Daemonizer

with PidFile('gefjun') as pid:
    with Daemonizer() as (is_setup, daemonizer):
        if is_setup:
            # This code is run before daemonization.
            print('do_things_here()')

        # We need to explicitly pass resources to the daemon; other variables
        # may not be correct
        is_parent, my_arg1, my_arg2 = daemonizer(
            pid.filename
        )

        if is_parent:
            # Run code in the parent after daemonization
            print('parent_only_code()')

# We are now daemonized, and the parent just exited.
print('code_continues_here()')

