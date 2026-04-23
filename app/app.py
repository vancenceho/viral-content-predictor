import streamlit as st
import pandas as pd
import numpy as np
import joblib
import json
from huggingface_hub import snapshot_download
import os

def predict_viral_proba(X_df, rf, xgb, lgbm, meta):
    p_rf = rf.predict_proba(X_df)[:, 1]
    p_xgb = xgb.predict_proba(X_df)[:, 1]
    p_lgbm = lgbm.predict_proba(X_df)[:, 1]
    X_meta = np.column_stack([p_rf, p_xgb, p_lgbm])
    return meta.predict_proba(X_meta)[:, 1]  # P(viral) from stacking

@st.cache_resource
def load_models():
    model_dir = snapshot_download(
        repo_id="vancenceho/vcp-combined-ensemble-stacking", 
        repo_type="model"
    )
    
    rf = joblib.load(os.path.join(model_dir, "rf_combined.joblib"))
    xgb = joblib.load(os.path.join(model_dir, "xgb_combined.joblib"))
    lgbm = joblib.load(os.path.join(model_dir, "lgbm_combined.joblib"))
    meta = joblib.load(os.path.join(model_dir, "stacking_ensemble_combined.joblib"))
    scaler = joblib.load(os.path.join(model_dir, "scaler_combined.joblib"))
    feature_info = joblib.load(os.path.join(model_dir, "feature_info_combined.joblib"))
    
    return rf, xgb, lgbm, meta, scaler, feature_info

rf, xgb, lgbm, meta, scaler, feature_info = load_models()

st.title("Viral Content Predictor")

st.write("Predict the probability of a piece of content going viral based on its audio features.")

st.subheader("Input Features (JSON Format)")

example_features = {
  "loudness": -6.746,
  "valence": 0.715,
  "danceability": 0.676,
  "energy": 0.461,
  "tempo_spotify": 87.917,
  "speechiness": 0.143,
  "liveness": 0.358,
  "acousticness": 0.0322,
  "instrumentalness": 1.01e-06,
  "spectral_contrast_3_std": 5.170992874268482,
  "spectral_contrast_4_std": 4.759121903050708,
  "spectral_bandwidth_mean": 2590.83220636304,
  "spectral_contrast_2_std": 4.837897000062121,
  "spectral_rolloff_std": 1858.701628080132,
  "mfcc_1_std": 82.66426849365234,
  "spectral_contrast_5_std": 4.091741647268559,
  "spectral_centroid_std": 923.7730260620716,
  "spectral_rolloff_mean": 5091.749766441321,
  "chroma_11_std": 0.2857026755809784,
  "chroma_2_std": 0.3013264536857605,
  "mfcc_6_std": 13.498969078063965,
  "chroma_4_std": 0.2908768355846405,
  "mfcc_10_std": 12.518518447875977,
  "chroma_9_std": 0.3441550433635711,
  "spectral_contrast_7_std": 3.69774693157058,
  "spectral_centroid_mean": 2251.1842893989788,
  "chroma_12_std": 0.3210540413856506,
  "mfcc_8_std": 11.250962257385254,
  "mfcc_9_std": 11.625442504882812,
  "chroma_7_std": 0.311981588602066,
  "spectral_bandwidth_std": 470.5496178243902,
  "mfcc_7_std": 12.826343536376951,
  "chroma_1_std": 0.2804908156394958,
  "mfcc_10_mean": 3.8493967056274414,
  "mfcc_13_std": 10.131909370422363,
  "spectral_contrast_6_std": 3.853216212923764,
  "onset_strength_mean": 1.7118542194366455,
  "chroma_5_std": 0.316478282213211,
  "zcr_std": 0.0603598449259818,
  "chroma_6_std": 0.2925746142864227,
  "mfcc_11_std": 10.548484802246094,
  "zcr_mean": 0.0802607895543085,
  "mfcc_12_std": 10.086920738220217,
  "onset_strength_std": 2.372274398803711,
  "mfcc_7_mean": -3.37680721282959,
  "chroma_8_std": 0.2913641929626465,
  "chroma_10_std": 0.3282630741596222,
  "mfcc_5_std": 16.198213577270508,
  "mfcc_1_mean": -123.95258331298828,
  "mfcc_4_std": 21.418142318725582,
  "mfcc_5_mean": 1.1399803161621094,
  "chroma_3_std": 0.2801650166511535,
  "mfcc_9_mean": 2.4127848148345947,
  "spectral_contrast_1_std": 5.154791389933442,
  "mfcc_12_mean": -0.0525405630469322,
  "spectral_contrast_3_mean": 19.73688914456044,
  "spectral_contrast_5_mean": 19.532899657624725,
  "spectral_contrast_4_mean": 19.97639126378684,
  "mfcc_3_std": 23.30025100708008,
  "mfcc_11_mean": -1.6210823059082031,
  "tonnetz_3_std": 0.0945150878361595,
  "tonnetz_6_mean": -0.0022060112245041,
  "tempo_librosa": 89.10290948275862,
  "tonnetz_2_mean": -0.040574970169434,
  "spectral_contrast_1_mean": 20.718470998959383,
  "tonnetz_5_std": 0.0374163347787399,
  "mfcc_6_mean": 12.988656044006348,
  "rms_std": 0.1214128285646438,
  "tonnetz_1_mean": -0.0112476646151929,
  "chroma_11_mean": 0.4024483859539032,
  "mfcc_4_mean": 30.147380828857425,
  "tonnetz_6_std": 0.0445685187084015,
  "chroma_12_mean": 0.4376142621040344,
  "chroma_1_mean": 0.3510372042655945,
  "chroma_2_mean": 0.3535699844360351,
  "chroma_4_mean": 0.3787552714347839,
  "chroma_6_mean": 0.3841779828071594,
  "chroma_7_mean": 0.4194181263446808,
  "chroma_5_mean": 0.4388349652290344,
  "chroma_9_mean": 0.5704683065414429,
  "spectral_contrast_7_mean": 48.22924787039285,
  "rms_mean": 0.1911688148975372,
  "chroma_10_mean": 0.4798530042171478,
  "chroma_8_mean": 0.4190760254859924,
  "chroma_3_mean": 0.3154186606407165,
  "mfcc_2_mean": 85.91410064697266,
  "explicit_False": True,
  "explicit_True": False,
  "mode_0": True,
  "mode_1": False,
  "time_signature_0": False,
  "time_signature_1": False,
  "time_signature_3": False,
  "time_signature_4": True,
  "time_signature_5": False
}

features_json = st.text_area(
    "Paste your features as JSON:",
    value=json.dumps(example_features, indent=2),
    height=300,
    key="features_input"
)

if st.button("Predict Virality"):
    try:
        # Parse JSON input
        features_dict = json.loads(features_json)
        
        # Get expected feature names from model
        expected_features = feature_info if isinstance(feature_info, list) else scaler.feature_names_in_
        
        # Create DataFrame with correct feature order
        X_df = pd.DataFrame([features_dict])
        X_df = X_df[expected_features]
        
        # Scale features
        X_scaled = scaler.transform(X_df)
        X_scaled_df = pd.DataFrame(X_scaled, columns=expected_features)
        
        # Make prediction
        viral_proba = predict_viral_proba(X_scaled_df, rf, xgb, lgbm, meta)[0]
        # Display result
        st.success(f"✅ Predicted Virality Probability: **{viral_proba:.2%}**")
        
        if viral_proba > 0.6:
            st.info("🚀 High likelihood of going viral!")
        elif viral_proba > 0.3:
            st.info("📈 Moderate likelihood of going viral.")
        else:
            st.warning("📊 Lower likelihood of going viral.")
            
    except json.JSONDecodeError as e:
        st.error(f"❌ Invalid JSON format: {e}")
    except KeyError as e:
        st.error(f"❌ Missing required feature: {e}")
    except Exception as e:
        st.error(f"❌ Error making prediction: {e}")

st.divider()
st.subheader("📊 Data Analysis Visualizations")

# Get the directory where this script is located
script_dir = os.path.dirname(os.path.abspath(__file__))
assets_dir = os.path.join(script_dir, "assets")

# Define image filenames
image_filenames = [
    "popularity_distribution.png",
    "audio_feature_pop_scatter.png",
    "key_audio_features_distribution.png",
    "point_biserial_correlation_features_virality.png",
    "correlation_heatmap_pop.png",
    "viral_non_viral_boxplots.png",
    "virality_rate_by_genre.png",
    "top_20_popular_artists.png",
]

image_titles = [
    "Popularity Distribution",
    "Audio Feature Population Scatter",
    "Key Audio Features Distribution",
    "Point-Biserial Correlation with Virality",
    "Correlation Heatmap",
    "Viral vs Non-Viral Boxplots",
    "Virality Rate by Genre",
    "Top 20 Popular Artists",
]

# Display images in a 2-column layout
cols = st.columns(2)
for idx, (filename, title) in enumerate(zip(image_filenames, image_titles)):
    image_path = os.path.join(assets_dir, filename)
    col = cols[idx % 2]
    with col:
        try:
            if os.path.exists(image_path):
                st.image(image_path, caption=title, width='stretch')
            else:
                st.warning(f"Image not found: {image_path}")
        except Exception as e:
            st.error(f"Error loading {title}: {e}")
