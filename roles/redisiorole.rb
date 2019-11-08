name 'redisiorole'
description 'single server master slave roles'

run_list(
  'redisio',
  'redisio::enable'
)

default_attributes({
  'redisio' => {
    'servers' => [
      {'port' => '6379'},
      {'port' => '6380'}
    ]
  }
})

