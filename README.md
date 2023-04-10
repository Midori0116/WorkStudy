# WorkStudy

## Postgres

### cmdによる接続注意事項  

cd C:\xxxx\pgsql\bin  

状態確認CMD  
pg_ctl -D "C:\xxx\pgsql\data" status  

もしpsql: エラー: "localhost" (::1)、ポート 5432でのサーバーへの接続に失敗しました: Connection refused (0x0000274D/10061)
        サーバーはそのホストで動作していて、TCP/IP接続を受け付けていますか?　
        \pgsql\data　postgresql.conf　のポート番号を確認
psql -h localhost -p ポート番号 -U spa -d spadb       
