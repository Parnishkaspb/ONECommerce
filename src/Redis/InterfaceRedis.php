<?php
namespace src\Redis;
interface InterfaceRedis
{
    public static function getInstance();
    public function startScript(int $ttl = 5): array;
    public function endScript() :array;
}