//-----------------------------------------------------------------------------
// Class: base_test
// Description: UVM 基础测试类
// Author: ICER Skill Package
// Date: 2024
// Version: 1.0
//-----------------------------------------------------------------------------

class base_test extends uvm_test;

    `uvm_component_utils(base_test)

    // 环境实例
    env m_env;

    // 配置对象
    env_config m_env_cfg;

    //=========================================================================
    // 构造函数
    //=========================================================================

    function new(string name = "base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //=========================================================================
    // 构建阶段
    //=========================================================================

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // 创建配置对象
        m_env_cfg = env_config::type_id::create("m_env_cfg");

        // 设置配置
        uvm_config_db#(env_config)::set(this, "m_env", "cfg", m_env_cfg);

        // 创建环境
        m_env = env::type_id::create("m_env", this);
    endfunction

    //=========================================================================
    // 连接阶段
    //=========================================================================

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    //=========================================================================
    // 结束阶段
    //=========================================================================

    virtual function void report_phase(uvm_phase phase);
        uvm_report_server server;
        int err_count;

        super.report_phase(phase);

        server = uvm_report_server::get_server();
        err_count = server.get_severity_count(UVM_ERROR) +
                    server.get_severity_count(UVM_FATAL);

        if (err_count == 0) begin
            `uvm_info("TEST_PASSED", "All tests passed!", UVM_LOW)
        end else begin
            `uvm_error("TEST_FAILED", $sformatf("%0d errors found", err_count))
        end
    endfunction

endclass


//=============================================================================
// Class: sanity_test
// Description: 冒烟测试
//=============================================================================

class sanity_test extends base_test;

    `uvm_component_utils(sanity_test)

    function new(string name = "sanity_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        sanity_seq seq;

        phase.raise_objection(this, "Starting sanity test");

        seq = sanity_seq::type_id::create("seq");
        seq.start(m_env.m_agent.m_sequencer);

        phase.drop_objection(this, "Finished sanity test");
    endtask

endclass


//=============================================================================
// Class: stress_test
// Description: 压力测试
//=============================================================================

class stress_test extends base_test;

    `uvm_component_utils(stress_test)

    // 测试参数
    int num_transactions = 1000;

    function new(string name = "stress_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // 从命令行获取参数
        void'($value$plusargs("NUM_TX=%0d", num_transactions));
    endfunction

    virtual task run_phase(uvm_phase phase);
        stress_seq seq;

        phase.raise_objection(this, "Starting stress test");

        seq = stress_seq::type_id::create("seq");
        seq.num_transactions = num_transactions;
        seq.start(m_env.m_agent.m_sequencer);

        phase.drop_objection(this, "Finished stress test");
    endtask

endclass
