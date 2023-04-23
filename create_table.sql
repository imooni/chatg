

create table t_settle_order
(
    settle_order_id       varchar(64)    not null comment '结算订单id'
        primary key,
    order_id              varchar(64)    not null comment '业务订单id',
    order_amount          decimal(15, 2) not null comment '订单金额',
    sale_amount           decimal(15, 2) null,
    order_days            int            not null comment '订单时长',
    order_left_amount     decimal(15, 2) not null comment '订单剩余金额',
    order_left_days       int            not null comment '订单剩余时长',
    settle_order_status   varchar(32)    not null comment '结算订单状态。
NOT_BEGIN-未开始结算;
SETTLED-已结算完成;
SETTLING-结算中;
FREEZED-已冻结;
REFUNDING-退款中;
REFUNDED-已退款;
CHANGED_SERVICE-已换服;
枚举值参考com.hexun.busi.settle.SettleOrderStatus',
    order_type            varchar(32)    not null comment '订单类型。
NORMAL-普通订单;
SHARE-引流订单;
REWARD-引流奖励订单;
SETTLE_CREATE-冲账创建订单;
枚举值参考com.hexun.busi.settle.OrderType',
    user_id               varchar(32)    not null comment '用户id',
    product_id            varchar(64)    not null comment '产品id',
    product_name          varchar(255)   not null comment '产品名称',
    price_strategy_id     varchar(64)    null comment '价格策略id',
    price_strategy_name   varchar(255)   null comment '价格策略名称',
    merchant_id           varchar(32)    not null comment '商户id',
    merchant_partner_id   varchar(32)    not null comment '商户合作伙伴id',
    merchant_partner_name varchar(64)    not null comment '商户合作伙伴名称',
    channel_id            varchar(64)    not null comment '渠道id',
    channel_name          varchar(64)    not null comment '渠道名称',
    project               varchar(32)    not null comment '项目',
    source                varchar(64)    null comment '来源',
    reward_partner_id     varchar(32)    null comment '引流合作伙伴id',
    reward_partner_name   varchar(64)    null comment '引流合作伙伴名称',
    reward_percent        decimal(6, 3)  null comment '引流奖励比例',
    reward_amount         decimal(15, 2) null comment '引流奖励金额',
    flow_id               varchar(32)    null comment '分账id',
    order_create_time     datetime       null comment '订单创建时间',
    order_pay_time        datetime       null comment '订单付款时间',
    order_begin_date      date           null comment '订单开始日期',
    remark                varchar(255)   null comment '备注',
    gmt_create_time       datetime       not null comment '创建时间戳',
    gmt_modify_time       datetime       not null comment '修改时间戳'
)
    comment '订单结算表' charset = utf8mb3;

create index ord_ind2
    on t_settle_order (order_id);

create index ord_ind3
    on t_settle_order (merchant_partner_id);

create index ord_ind4
    on t_settle_order (merchant_partner_name);

create index ord_ind5
    on t_settle_order (user_id, product_id, price_strategy_id);

create index ord_ind6
    on t_settle_order (settle_order_status);

create index ord_ind7
    on t_settle_order (order_type);

create index ord_ind8
    on t_settle_order (merchant_id, channel_id, merchant_partner_id, project);
    
 
###


create table t_order_record
(
    record_id          varchar(64) charset utf8mb3  not null comment '主键，记录id'
        primary key,
    settle_order_id    varchar(64) charset utf8mb3  not null comment '结算订单id',
    order_id           varchar(64) charset utf8mb3  not null comment '业务订单id',
    modify_type        varchar(20) charset utf8mb3  null comment '订单变动类型：',
    modify_status      varchar(20) charset utf8mb3  not null comment '变更执行状态：SUCCESS;FAILED',
    status_before      varchar(32) charset utf8mb3  null comment '变更前状态',
    status_after       varchar(32) charset utf8mb3  null comment '变更后状态',
    amount_left_before decimal(15, 2)               null comment '变更前金额',
    amount_left_after  decimal(15, 2)               null comment '变更后金额',
    days_left_before   int                          null comment '变更前剩余天数',
    days_left_after    int                          null comment '变更后剩余天数',
    settle_date        date                         null comment '系统自动结算-结算日期',
    remark             varchar(255) charset utf8mb3 null comment '变更说明',
    gmt_create_time    datetime                     not null comment '创建时间'
)
    comment '订单变动记录表';

create index t_order_record_gmt_create_time_settle_order_id_index
    on t_order_record (gmt_create_time, settle_order_id);
