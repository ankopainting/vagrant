require "test_helper"

class ImportVMActionTest < Test::Unit::TestCase
  setup do
    @klass = Vagrant::Action::VM::Import
    @app, @env = mock_action_data
    @instance = @klass.new(@app, @env)

    ovf_file = "foo"
    @box = mock("box")
    @box.stubs(:name).returns("foo")
    @box.stubs(:ovf_file).returns(ovf_file)
    @env.env.stubs(:box).returns(@box)

    @env.env.vm = Vagrant::VM.new(:env => @env.env, :name => "foobar")

    VirtualBox::VM.stubs(:import)

    @vm = mock("vm")
    @vm.stubs(:uuid).returns("foobar")
  end

  should "call import on VirtualBox with proper base" do
    VirtualBox::VM.expects(:import).once.with(@env.env.box.ovf_file).returns(@vm)
    @instance.call(@env)
  end

  should "call next in chain on success and set VM" do
    VirtualBox::VM.stubs(:import).returns(@vm)
    @app.expects(:call).with(@env).once
    @instance.call(@env)

    assert_equal @vm, @env["vm"].vm
  end

  should "mark environment erroneous and not continue chain on failure" do
    @app.expects(:call).never
    assert_raises(Vagrant::Errors::VMImportFailure) {
      @instance.call(@env)
    }
  end

  should "run the destroy action on recover" do
    env = mock("env")
    destroy = mock("destory")
    env.expects(:[]).with("actions").returns(destroy)
    destroy.expects(:run).with(:destroy)
    @instance.recover(env)
  end
end
