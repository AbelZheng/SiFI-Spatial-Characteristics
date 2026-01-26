这个文件夹包括了本研阶段 Dounble Flash Illusion 研究的主要程序和数据：

- 结题论文（pdf/word 格式）；
- 图：论文中所有的配图单独储存；
- Exp1_Analysis （针对实验一的数据进行分析）：
  - DFI_1_Data.xlsx ：预处理之后的，每个被试各个条件下反应数据的均值；
  - DFI_1_Analysis.ipynb：基于 jupyter notebook 的脚本，是进行各种数据处理和绘图的文件。可以通过 html 脚本进行预览。其中对分析步骤也有文字说明；
  - DFI_1_Data.db：是将数据和变量导出的文件，可以直接在notebook中引入；
  - csv文件：针对某一步数据分析所导出的数据汇总，在notebook中存在描述，之后会在JASP中进行分析；
  - jasp文件：是经由JASP对csv文件进行的统计分析；
  - RawData：原始mat文件和导出为xlsx的处理。
- Exp2_Analysis （针对实验二的数据进行分析）：
  - Data Analysis 文件夹的内容的命名方式都和Exp_1一致；
  - Modeling 文件夹是进行建模的处理：
    - ipynb 的文件中对每一步有一定的解释；
    - 也可以直接打开html文件预览。
- Exp3_Analysis（针对实验三的数据进行分析）：
  - Data Analysis 文件夹的内容的命名方式都和Exp_1一致；
- Exp Codes （各个实验的实验程序）