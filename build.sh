echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
cd /home/ssda/git/php-zatca-xml/

source venv/bin/activate 2> /dev/null

echo "run main python -----------"
python main.py
echo "run processe bash ---------"
sh processe.sh
echo "run push bash -------------"
sh push.sh
