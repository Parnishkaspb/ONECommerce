<?php

namespace src\Redis;

class Redis implements InterfaceRedis
{
    private static $redis;
    private static $instance = null;

    private function __construct()
    {
    }

    public static function getInstance()
    {
        if (self::$instance === null) {
            self::$instance = new self();
            self::$redis = new \Redis();
            self::$redis->connect('127.0.0.1', 6379);
        }
        return self::$instance;
    }

    public function startScript(int $ttl = 5): array
    {
        if (self::$redis->exists("Not using")) {
            return [
                'status'  => false,
                'message' => "Ключ 'Not using' существует! Выполнение скрипта невозможно!"
            ];
        }
        self::$redis->setex("Not using", $ttl, "chatGPT:)");
        return [
            'status'  => true,
            'message' => "Выполнение скрипта начинается! Время до конца работы: $ttl"
        ];
    }

    public function endScript(): array
    {
        if (self::$redis->exists("Not using")) {
            self::$redis->del("Not using");
            return [
                'status'  => true,
                'message' => 'Выполнение скрипта закончено!'
            ];
        }

        return [
            'status'  => false,
            'message' => 'Ключа не существует! Невозможно завершить скрипт!'
        ];
    }
}