/* first.jai

copying the basic metaprogram from howto 450
*/

build :: () {
    // 
    // Create a second workspace to contain the program we want to compile.
    // We can pass a name to compiler_create_workspace that gets reported
    // back to us in error messages:
    //
    w := compiler_create_workspace("Target Program");
    if !w {
        print("Workspace creation failed.\n");
        return;
    }

    // Let's set some build options on the target program.
    // For now, just the executable name!
    // We must set the build options before adding any source.
    // The compiler disallows this afterward, because it would result
    // in inconsistent compilation.
    target_options := get_build_options(w);
    target_options.use_natvis_compatible_types = true;  // for looking at arrays in vscode
    target_options.output_executable_name = "aoc";
    set_build_options(target_options, w);

    // As the compiler builds the target program, we can listen in on messages
    // that report the status of the program. In later examples we can use
    // these messages to do sophisticated things, but for now, we'll just
    // use them to report on the status of compilation.
    
    // To tell the compiler to give us messages, we need to call compiler_begin_intercept
    // before we add any code to the target workspace.
    compiler_begin_intercept(w);

    // Now let's add the code.
    add_build_file(tprint("%/aoc.jai", #filepath), w);  // @Cleanup: Fix this to not require #filepath.

    // Call message_loop(), which is a routine of ours below that will receive the messages.
    // message_loop();  // NOTE (brice): i removed this

    // When we're done, message_loop will return.
    // We call compiler_end_intercept to tell the compiler we are done.
    compiler_end_intercept(w);

    //
    // The goal of this program is actually to compile another program;
    // none of the code in this file is intended to end up in an executable
    // of any kind. So, we tell the compiler not to make an executable for us:
    //

    set_build_options_dc(.{do_output=false});
}

#run build();

#import "Basic";
#import "Compiler";

