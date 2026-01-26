# SiFI-Spatial-Characteristics
This repositiry stores the data and analysis code for project sound-induced flash illusion.
The main contents of this repository are organized as follows:

### Experiment 1 Analysis (Spatial Eccentricity) 

- `Exp1_Analysis/`
  - `DFI_1_Data.xlsx`: Preprocessed data containing mean response values for each participant across conditions.
  - `DFI_1_Analysis.ipynb`: Jupyter Notebook script for data processing and visualization. Includes detailed markdown annotations explaining the analysis steps. 
  - `DFI_1_Data.db`: Database/variable file exported for direct import into the notebook.
  - `*.csv`: Aggregated datasets exported from specific analysis steps, intended for statistical analysis in JASP.
  - `*.jasp`: JASP files containing the statistical analysis results (ANOVA/Bayesian Factors).
  - `RawData/`: Original data files (MATLAB `.mat`) and converted `.xlsx` files. 

### Experiment 2 Analysis (Bayesian Modeling)

- `Exp2_Analysis/`
  - Data Analysis: Follows the same naming convention and structure as Experiment 1. 
  - Modeling: Contains the Hierarchical Bayesian Modeling code (using PyMC). 
    - `*.ipynb`: Python scripts of the model construction and comparison.

### Experiment 3 Analysis (Spatial Congruence)

- `Exp3_Analysis/`
  - **Data Analysis**: Follows the same naming convention and structure as Experiment 1.

### Experiment Codes

- `Exp_Codes/`: The raw experimental scripts written in MATLAB via Psychtoolbox-3.

------

## Requirements

To run the analysis code, you will need: 

- Python 3.x
  - Jupyter Notebook
  - Pandas, NumPy, Matplotlib, Seaborn
  - PyMC (for Bayesian Modeling)
- JASP (for statistical analysis verification)
- MATLAB + Psychtoolbox-3 (to run the experiment scripts)

## Contact

If you have any questions regarding the data or code, please verify the content via the provided analysis scripts or contact the author. 
