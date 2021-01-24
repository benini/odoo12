# odoo-12

Crea un istanza di odoo-12 community (l'ultima versione con la contabilità gratuita) accessibile da browser all'URL localhost:8069

Avviare con:
sudo docker-compose up

Rimuovere moduli sponsorizzati:  
unsplash  
partner_autocomplete
mail_bot

Per la contabilità italiana installare i moduli:  
l10n_it_fatturapa_in_rc  
l10n_it_vat_registries_split_payment  
l10n_it_vat_statement_split_payment  
l10n_it_vat_statement_communication  
l10n_it_account_balance_report  
l10n_it_central_journal  
l10n_it_ricevute_bancarie  
account_payment_term_extension  
account_bank_statement_import_txt_xlsx  

In Impostazioni -> "Attiva la modalità sviluppatore"  
In Impostazioni -> "Gestisci i diritti di accesso" selezionare "Mostrare funzionalità contabili complete".  
In Impostazioni -> "Funzioni tecniche" -> "Struttura database" -> "Accuratezza decimale" consentire 4 cifre per "Product Price".  
In Impostazioni -> "Impostazioni Generali" -> "Contabilità" impostare lo stile formato di anteprima delle fatture elettroniche a "AssoSoftware".  
In Fatturazione -> Configurazione -> Imposte disattivare le aliquote non usate, aggiungere il conto per la liquidazione IVA, i codici N1 e N2.  

Backup:  
localhost:8069/web/database/manager

Aggiornamenti:  
Eliminare i container: sudo docker system prune --all  
o ricostruirli: sudo docker-compose build  
Avviare odoo con l'aggiornamento moduli: sudo docker-compose run --service-ports web odoo-src/odoo-bin -d odoo2020 --init=base_vat_sanitized --update=all  
Aprire il database in odoo e verificare che nel terminale docker non ci siano errori.  
