cd /home/ssda/git/php-zatca-xml/

source venv/bin/activate

echo "invoice zatca start"
echo "run main python"
python main.py
echo "run processe bash"
sh processe.sh
echo "run push bash"
sh push.sh
echo "invoice zatca end"
