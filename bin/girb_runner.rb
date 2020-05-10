require 'puts_debuggerer'

include Glimmer

# Hijack Shell#start_event_loop default behavior to ensure disposing a display upon closing a shell inside girb

Glimmer::SWT::ShellProxy.class_eval do
  alias start_event_loop_original start_event_loop
  def start_event_loop
    start_event_loop_original
    Glimmer::SWT::DisplayProxy.instance.dispose
  end
end
