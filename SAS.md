# SAS
## 名寄せ

  論文：  
  https://www.sas.com/content/dam/SAS/ja_jp/doc/event/sas-user-groups/usergroups11-b-10.pdf  
  例１のコード
　　
  data charlog; /* charlogというデータセットを定義 */
 set inputdata; /* inputdataというデータセットからデータを読み込む */
 length _obs _col 4 _key $2 _code $4; /* 新しい変数を定義して長さを指定 */
 keep _:; /* 変数 _obs, _col, _key, _code 以外の変数は削除 */

 if text=' ' then return; /* もしtext変数が空白文字なら、次のレコードへスキップ */

 _obs=_N_; /* _obs変数に現在の観測値（レコード）番号を格納 */
 len=klength(text); /* len変数にtext変数の文字列の長さを格納 */

 do i=1 to len; /* len変数の長さだけループ */
   _col=i; /* _col変数に現在の文字の位置を格納 */
   _key=ksubstr(text, i, 1); /* _key変数に文字列textのi番目の文字を格納 */
   _code=put(_key, $hex.); /* _code変数に文字のバイトコードを16進数文字列として格納 */

   /* もしバイトコードの最初の文字が '8','9','E','F' のいずれかでないなら、
   バイトコードの最初の2文字を取り出す（半角文字とみなす） */
   if substr(_code,1,1) not in ('8','9','E','F') then _code=substr(_code,1,2);

   output; /* データセットに行を出力 */
 end;
run;

proc freq data=charlog; /* charlogデータセットを用いて頻度分析を実行 */
 tables _code*_key /list missing; /* _codeと _key のクロス集計を行い、欠損値も表示 */
run;

  
