---
marp: true
theme: academic
paginate: true
math: mathjax
---

<!-- _class: lead -->
# PCPの文字列制約を介した不可能性判定と, ParikhAutomaton の高速な空性判定

大森章裕

---

<!-- _header: 目次 -->

1. Post's Correspondence Problem について
2. PCPの文字列制約での定式化
3. 問題の緩和
4. 整数計画としての定式化
5. SMTソルバ(Z3)との比較
6. 今後

---
<!-- _header: Post's Correspondence Problem -->
- アルファベット集合 $\Sigma$

サイズ $s$のPCPインスタンスとは, $s$ 個の $\Sigma$ 上の word のペア (タイル) 
$$((g_1, h_1), \dots ,(g_s, h_s))$$
このインスタンスの解とは, 添字の列 $(i_1, i_2, \dots i_n) \in \{1,\dots, s\}^+$
$$g_{i_1}g_{i_2}\dots g_{i_n} = h_{i_1}h_{i_2}\dots h_{i_n}$$
となるもの

---
<!-- _header: Post's Correspondence Problem -->
ex. サイズ3のPCPインスタンス
$$ \begin{bmatrix} g\\ h \\\end{bmatrix} = \begin{bmatrix} 100 & 0 & 1 \\ 1 & 100 & 00 \\\end{bmatrix} $$
解
$$ "1311322" \in \{1,2,3\}^+ $$
実際並べてみると...
$$\begin{bmatrix} 100 & 1 & 100 & 100 & 1 & 0 & 0 \\ 1 & 00 & 1 & 1 & 00 & 100 & 100 \\\end{bmatrix} $$

---
<!-- _header: 文字列制約問題としての定式化 -->
- PCPのインスタンス $P = (T_1, T_2)$
- $T_1, T_2$ : 上段,下段に対応するトランスデューサ
- 制約: $T_1(x) = T_2(x)$

ex.
$$ \begin{bmatrix} 1111 & 1101 & 11 \\ 1110 & 1 & 1111 \\\end{bmatrix} $$
$T_1$ ![](assets/t1.dot.svg)   $T_2$ ![](assets/t2.dot.svg)

---
<!-- _header: Post's Correspondence Problem -->
- 決定不能問題
- 実用性はあんまりない
  - 文字列制約の難しい部分問題としての位置付けを重視
  - このあと提案する手法が,PCPに対して有効→文字列制約に一般化した後でも期待できるね,という話


- 肯定的に判定する
  - 実際に解を見つける
  - 探索的手法が強い
- 否定的に判定する
  - 今回はこちらがメイン

---
<!-- _header: PCP を否定的に解決する -->
PCPの文字列制約 $\mathbf{T_1(x)=T_2(x)}$ を効率よく解ける形に緩和したい

案
- $Length(T_1(x)) = Length(T_2(x))$
- $Parikh(T_1(x)) = Parikh(T_2(x))$
- $Count_{100101}(T_1(x)) = Count_{100101}(T_2(x))$
  - $Count_{100101}(w)$ は, $w$ 中の100101の出現回数
- $\mathbf{Parikh(W(T_1(x))) = Parikh(W(T_2(x)))}$ W: Transducer
  - $W$をそれぞれ合成すれば,上から二番目の形

---
<!-- _header: $Count_{100101}(T_1(x)) = Count_{100101}(T_2(x))$ -->

下のトランスデューサーをWにすれば

<img src="assets/sub.dot.svg" style="width:100%;" />

$$\mathbf{Parikh(W(T_1(x))) = Parikh(W(T_2(x)))}$$
の形になる

---
<!-- _header: $Parikh(T_1(x)) = Parikh(T_2(x))$ -->

- ベクトル出力トランスデューサ $Parikh(T_1)$, $Parikh(T_2)$

$S = (Q, \Sigma_{idx}, \Sigma_{pcp}, \Delta, q_0, q_f)$
- $Q = Q_1\times Q_2$
- $\Delta \subset Q\times \Sigma_{idx} \times \mathbb{Z}^{ \Sigma_{pcp}} \times Q$
- $\Delta = \{((p_1,p_2),a,{\color{red}\mathbf{v_1-v_2}},(q_1,q_2)) | (p_1,a,v_1,q_1)\in \Delta_1, (p_2,a,v_2,q_2)\in \Delta_2\}$
  - 普通の直積構成で,出力するベクトルが差になっている

この$S$に,論理式 $\varphi(v)= (v = 0)$ を課したParikh Automaton を考える

---
<!-- _header: ex -->

<div style="display:flex; justify-content:space-between; align-items:center; width:100%;">
<div style="display: flex;align-items: center;">T1: <img src=assets/mult_l.dot.svg/></div>
<div style="display: flex;align-items: center;">T2: 
<img src=assets/mult_r.dot.svg/>
</div>
</div>
<img src=assets/mult.dot.svg style="width:100%"/>

制約: $v = \{a:0, b:0\}$

---
<!-- _header: ParikhAutomaton S の解き方（これまで） -->
<!-- 解いた結果、yを得たい -->
1. $S$ の有向グラフとしての表現 $G$ とする
2. 各辺 $e$ に対して,その辺を通る回数を表す変数 $\color{red}y_e$に対して, $G$ の開始頂点から受理頂点への路をちょうど全て捉える論理式$\psi$を構成$^1$
    - $\psi(y) \iff \exists t(Gの開始頂点から受理頂点への路), \forall e, y_e=|t|_e$
> $^1$等号否定入り文字列制約のStreaming String Transducerを用いた充足可能性判定
3. $\Sigma_{e} y_e \cdot v_e = 0\ (辺eで出力するベクトルv_e)$ と, 2 の論理式の論理積をSMTソルバに解かせる ($y$の具体的な値を得る. 路の復元は容易)

**Z3が遅いので,改善したい. 混合整数計画問題として定式化して高速化**

---
<!-- _header: やりたいこと-->
<img src=assets/y_example.dot.svg  style="width:100%"/>

式を解いて $y$ (上図)を得て, 元のオートマトン上の遷移を復元
0,0,1,1,2,3,0,1,2,3


---
<!-- _header: オートマトンの受理する路を捉える論理式 -->
各辺 $e$ に対して,その辺を通る回数を表す変数 $y_e$ に対して, $G$ の開始頂点から受理頂点への路をちょうど全て捉える論理式$\psi$を構成

- euler condition (流量保存則)
  - これが満たされている$y$の, どの連結成分も一筆書き可能（対応する路が存在）
  - **最大流問題をLP定式化したときの制約部分**
- connectivity constraint
  - 連結成分が複数あっては困るので,それを制限する
  - **素直に定式化できない**
    - 線形計画は,論理式の**OR**が直接的には扱えないため
    - やるにしても,指数個の制約が必要 or 効率が悪い

---
<!-- _header: euler condition -->

$$ \Sigma_{e\in target(v)} y_e - \Sigma_{e\in source(v)} y_e = \left\{
\begin{array}{ll}
-1 & vが開始頂点 \\
1 & vが受理頂点 \\
0 & otherwise
\end{array}
\right.
$$
<img src="assets/flow.dot.svg" width="100%"/>

---
<!-- _header: connectivity constraint (連結性) -->

開始頂点からの到達可能性を表す変数を用意して,頑張って表現する
$$\left(n_q>0\right) \wedge\left(\bigvee_{\delta \ni \text { d:target }(d)=q}\left(z_q=z_{\text {source }(d)}+1\right) \wedge\left(y_d>0\right) \wedge\left(z_{\text {source }(d)} \geq 0\right)\right)$$
(今回使わないので,詳細は省く)


---
<!-- _header: connectivity constraint を扱うアルゴリズム-->
1. euler condition のみで解く
2. 得られた $y$ が連結なら $y$ を出力して停止する
3. そうでないなら, 開始頂点と連結でない頂点 $v$ を一つ取ってきて
    - $v$ に到達するパターン
      - そういう制約を入れる. 次スライド
    - $v$ に到達しないパターン
      - $\forall e\in target(v)\cup source(v), y_e = 0$ を制約に追加する

  と場合分けして再帰的に解く
<!-- どちらのパターンでもUNSAT → UNSAT -->

---
<!-- _header: connectivity constraint を扱うアルゴリズム-->

<img src="assets/connectivity_branch.mmd.svg" style="display:block; object-fit:cover; margin-top:auto; margin-bottom:auto;" />

- 頂点n個なら最悪で $O(2^n)$ 回, 混合整数計画問題を解く
- 各分岐を行う時, incremental に制約の追加を行い, 出ていくときに制約の削除を行う
---
<!-- _header: $v$ に到達する制約 -->
**$V=\{v_1, v_2,...,v_n\}$ の全てへ到達することを制約したい**
各辺 $e$ について,新しい変数 $z_e$ (連続で可) を用意
1. $$\forall e, z_e \le y_e$$
2. 各頂点 $v$ について
$$ \Sigma_{e\in target(v)} z_e - \Sigma_{e\in source(v)} z_e = \left\{
\begin{array}{ll}
-|V| & vが開始頂点 \\
1 & v\in V \\
0 & otherwise
\end{array}
\right.
$$
**$V$のどの頂点も$z$上で開始頂点から連結になっている**(次スライド)
制約 1 から, $y$ 上でも開始頂点から連結になっている

---
<!-- _header: $V$のどの頂点も$z$上で開始頂点から連結になっている -->
- z上の連結成分 $W$ から誘導される辺の集合 $E_W$
<!-- Wとそれ以外を跨ぐ辺 -->
$$W が z 上の連結成分 \implies \forall{e\in (source(W)\cup target(W))\setminus E_W}, z_e = 0$$
$$ \Sigma_{v\in W}(\Sigma_{e\in target(v)} z_e - \Sigma_{e\in source(v)} z_e)
\\ = \Sigma_{e\in target(W)\setminus E_W}z_e - \Sigma_{e\in source(W)\setminus E_W}z_e + (W内部) = 0
$$
<!-- W内部は,どの辺もちょうど1回たされて、１回ひかれるので0 -->
また, $\ \ \   =  \Sigma_{v\in W}(\left\{
\begin{array}{ll}
-|V| & vが開始頂点 \\
1 & v\in V \\
0 & otherwise
\end{array}
\right.) 
$ 

つまり, $W$ が $V$ の頂点を含むなら,$W$ は開始頂点も含まないといけない


---
<!-- _header: 混合整数計画 vs SMT(QF_LIA)-->
#### 混合整数計画
- 何らかの値の最小化,最大化もできる
  - Parikh Automaton の言語の最小元が取ってこれる等
  - 肯定的解決のための探索で枝狩りに下界として利用可能
- 線形緩和によって,速度と精度のトレードオフができる
- incremental な制約の変更に強い
#### SMT
- 扱える論理式の幅が広い 
  - 混合整数計画はORが直接的には扱えない
  - 非線形な式を入れても扱えるソルバは多い(決定不能にはなるが)

---
<!-- _header: 実験 -->
TBD

- 先行研究で未解決だったPCPインスタンスで結構な数のunsatを証明 (手元の未解決の8割くらいは証明できそう?)
  - トランスデューサWとして,色々な単語$w$についての$Count_{w}$の積を使用
- 小さいケースから大きいケースまでZ3より圧倒的に速い(次ページ)
- 線形緩和したときの性能
  - 緩和せずUNSAT証明できるけど,線形緩和だけでは不可能みたいなケースはほぼ無さそう？
    - 現状,一番効率よくUNSAT判定ができているのは,ある程度大きいトランスデューサで線形緩和を使う方法
  - 最小値は半分くらいになる感じ？

---
<!-- _header: 実験 -->

<img src=assets/time.png style="display:block;margin-left:auto; margin-right:auto; height:100%; object-fit:cover;">

---
<!-- _header: 実験 -->

$$ \begin{bmatrix} 111 & 111 & 000 & 1 \\ 110 & 101 & 00 & 111 \\\end{bmatrix} $$

$$ \begin{bmatrix} 111 & 111 & 000 & 11 \\ 110 & 101 & 00 & 111 \\\end{bmatrix} $$

$$ \begin{bmatrix} 1111 & 0101 & 11 \\ 1010 & 01 & 111 \\\end{bmatrix} $$
---
<!-- _header: 今後 -->
- 他のParikhAutomatonに適用した時の有効性を確認する
- equalityの緩和方法は, PCPの文字列制約に限らず一般の文字列制約問題に一般化することが可能なはず
  - unsat性に関してあまり研究が進んでいる様子はなさそう？
- 良いトランスデューサWとは何なのか？ 
- アルファベットが増えるとちょっとまずいかもしれない
