<?php

use src\Redis\Redis;

$redisSingleton = Redis::getInstance();
$answer = $redisSingleton->startScript();
if (!$answer['status']) {
    echo $answer['message'];
    return;
}
echo $answer['message'];
echo "Скрипт выполняет свою работу \n";


$answer = $redisSingleton->endScript();
if (!$answer['status']) {
    echo $answer['message'];
    return;
}

echo $answer['message'];