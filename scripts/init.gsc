init()
{
    thread redux\hooks::hooks();
    thread redux\common::init();
    thread redux\bounces::init();
    thread thirdparty\bot_warfare\_bot::init();
}