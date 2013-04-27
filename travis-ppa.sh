#! /bin/sh
if [ $PPA != 'none' ];then
    sudo apt-add-repository -y $PPA;
    sudo apt-get update -qq;
fi
