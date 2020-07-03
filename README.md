# odoo-12

Crea un istanza di odoo-12 community (l'ultima versione con la contabilità gratuita) accessibile da browser all'URL localhost:8069

Avviare con:
sudo docker-compose up

Rimuovere moduli sponsorizzati:  
unsplash  
partner_autocomplete

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

In Administrator -> Preferenze disattivare l'OdooBot  
In Impostazioni -> "Gestisci i diritti di accesso" selezionare "Mostrare funzionalità contabili complete".  
In Impostazioni -> "Impostazioni Generali" -> "Contabilità" impostare lo stile formato di anteprima delle fatture elettroniche.  
In Impostazioni -> "Funzioni tecniche" (attivare la modalità di debug) -> "Struttura database" -> "Accuratezza decimale" consentire 4 cifre per "Product Price".  
In Fatturazione -> Configurazione -> Imposte disattivare le aliquote non usate, aggiungere il conto per la liquidazione IVA, i codici N1 e N2.  

Backup:
localhost:8069/web/database/manager
