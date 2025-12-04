from gamma.database import engine
from gamma.bill import start
from gamma.credit_note import credit

start(engine)
credit(engine)
