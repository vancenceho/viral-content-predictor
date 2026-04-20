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

