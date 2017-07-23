require_relative '../lib/glimmer_application'
include Java
$CLASSPATH << GlimmerApplication::SWT_JAR_FILE
require_relative '../lib/glimmer'
include Glimmer
