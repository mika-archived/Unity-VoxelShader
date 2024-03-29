﻿/*-------------------------------------------------------------------------------------------
 * Copyright (c) Fuyuno Mikazuki / Natsuneko. All rights reserved.
 * Licensed under the MIT License. See LICENSE in the project root for license information.
 *------------------------------------------------------------------------------------------*/

using System;

using UnityEditor;

using UnityEngine;

namespace Mochizuki.VoxelShader
{
    public enum ThinOutSource
    {
        MaskTexture,

        NoiseTexture,

        ShaderProperty
    }

    public enum UvSamplingSource
    {
        Center,

        First,

        Second,

        Last
    }

    public enum VoxelSource
    {
        Vertex,

        ShaderProperty
    }

    public class VoxelShaderGui : ShaderGUI
    {
        private const int VersionMajor = 0;
        private const int VersionMinor = 1;
        private const int VersionPatch = 0;

        private bool _isInitialized;
        private bool _isStencil;
        private bool _isTransparent;

        public override void OnGUI(MaterialEditor me, MaterialProperty[] properties)
        {
            var material = (Material) me.target;

            _Alpha = FindProperty(nameof(_Alpha), properties, false);
            _Culling = FindProperty(nameof(_Culling), properties, false);
            _EnableAnimation = FindProperty(nameof(_EnableAnimation), properties, false);
            _EnableThinOut = FindProperty(nameof(_EnableThinOut), properties, false);
            _EnableVoxelization = FindProperty(nameof(_EnableVoxelization), properties, false);
            _MainTex = FindProperty(nameof(_MainTex), properties, false);
            _StencilCompare = FindProperty(nameof(_StencilCompare), properties, false);
            _StencilFail = FindProperty(nameof(_StencilFail), properties, false);
            _StencilPass = FindProperty(nameof(_StencilPass), properties, false);
            _StencilReference = FindProperty(nameof(_StencilReference), properties, false);
            _StencilZFail = FindProperty(nameof(_StencilZFail), properties, false);
            _ThinOutMaskTex = FindProperty(nameof(_ThinOutMaskTex), properties, false);
            _ThinOutMinSize = FindProperty(nameof(_ThinOutMinSize), properties, false);
            _ThinOutNoiseTex = FindProperty(nameof(_ThinOutNoiseTex), properties, false);
            _ThinOutNoiseThresholdB = FindProperty(nameof(_ThinOutNoiseThresholdB), properties, false);
            _ThinOutNoiseThresholdG = FindProperty(nameof(_ThinOutNoiseThresholdG), properties, false);
            _ThinOutNoiseThresholdR = FindProperty(nameof(_ThinOutNoiseThresholdR), properties, false);
            _ThinOutSource = FindProperty(nameof(_ThinOutSource), properties, false);
            _UVSamplingSource = FindProperty(nameof(_UVSamplingSource), properties, false);
            _VoxelMinSize = FindProperty(nameof(_VoxelMinSize), properties, false);
            _VoxelOffsetN = FindProperty(nameof(_VoxelOffsetN), properties, false);
            _VoxelOffsetX = FindProperty(nameof(_VoxelOffsetX), properties, false);
            _VoxelOffsetY = FindProperty(nameof(_VoxelOffsetY), properties, false);
            _VoxelOffsetZ = FindProperty(nameof(_VoxelOffsetZ), properties, false);
            _VoxelSize = FindProperty(nameof(_VoxelSize), properties, false);
            _VoxelSource = FindProperty(nameof(_VoxelSource), properties, false);
            _ZWrite = FindProperty(nameof(_ZWrite), properties, false);

            _isTransparent = material.shader.name.Contains("Transparent");
            _isStencil = material.shader.name.Contains("Stencil");

            OnInitialize(material);

            OnMainGui(me);
            OnVoxelGui(me);
            OnAnimationGui(me);
            OnThinOutGui(me);
            if (_isStencil)
                OnStencilGui(me);
            OnOthersGui(me);

            using (new EditorGUILayout.VerticalScope())
            {
                EditorStyles.label.wordWrap = true;

                using (new Section("Performance Note"))
                    EditorGUILayout.LabelField("When the options marked with * are enabled, there is a small performance impact for rendering.");
            }

            using (new EditorGUILayout.HorizontalScope())
            {
                GUILayout.FlexibleSpace();
                GUILayout.Label($"Mochizuki Voxel Shader {VersionMajor}.{VersionMinor}.{VersionPatch}", EditorStyles.boldLabel);
            }
        }

        private void OnInitialize(Material material)
        {
            if (_isInitialized)
                return;
            _isInitialized = true;

            foreach (var keyword in material.shaderKeywords)
                material.DisableKeyword(keyword);

            material.SetInt("_MajorVersion", VersionMajor);
            material.SetInt("_MinorVersion", VersionMinor);
            material.SetInt("_PatchVersion", VersionPatch);
        }

        private void OnMainGui(MaterialEditor me)
        {
            using (new Section("Main"))
            {
                GUILayout.Label("Main Color & Texture", EditorStyles.boldLabel);

                me.TexturePropertySingleLine(new GUIContent("Main Texture"), _MainTex);
                me.TextureScaleOffsetProperty(_MainTex);

                if (_isTransparent)
                    me.ShaderProperty(_Alpha, "Alpha");
            }
        }

        private void OnVoxelGui(MaterialEditor me)
        {
            using (new Section("Voxel"))
            {
                GUILayout.Label("Voxelization", EditorStyles.boldLabel);

                me.ShaderProperty(_EnableVoxelization, "Enable Voxelization");

                using (new EditorGUI.DisabledGroupScope(!IsEqualsTo(_EnableVoxelization, true)))
                {
                    me.ShaderProperty(_VoxelSource, "Source");
                    me.ShaderProperty(_UVSamplingSource, "UV Sampling Source");

                    using (new EditorGUI.DisabledGroupScope(!IsEqualsTo(_VoxelSource, (int) VoxelSource.Vertex)))
                        me.ShaderProperty(_VoxelMinSize, "Minimal Size");
                    using (new EditorGUI.DisabledGroupScope(!IsEqualsTo(_VoxelSource, (int) VoxelSource.ShaderProperty)))
                        me.ShaderProperty(_VoxelSize, "Size");

                    me.ShaderProperty(_VoxelOffsetN, "Offset Normal");
                    me.ShaderProperty(_VoxelOffsetX, "Offset X");
                    me.ShaderProperty(_VoxelOffsetY, "Offset Y");
                    me.ShaderProperty(_VoxelOffsetZ, "Offset Z");
                }
            }
        }

        private void OnAnimationGui(MaterialEditor me)
        {
            using (new Section("Animation"))
            {
                GUILayout.Label("Voxel Animation", EditorStyles.boldLabel);

                me.ShaderProperty(_EnableAnimation, "Enable Voxel Animation");
            }
        }

        private void OnThinOutGui(MaterialEditor me)
        {
            using (new Section("ThinOut"))
            {
                GUILayout.Label("Voxel ThinOut", EditorStyles.boldLabel);

                me.ShaderProperty(_EnableThinOut, "Enable Voxel ThinOut");

                using (new EditorGUI.DisabledGroupScope(!IsEqualsTo(_EnableThinOut, true)))
                {
                    me.ShaderProperty(_ThinOutSource, "ThinOut Source");

                    using (new EditorGUI.DisabledGroupScope(!IsEqualsTo(_ThinOutSource, (int) ThinOutSource.MaskTexture)))
                        me.TexturePropertySingleLine(new GUIContent("Mask Texture"), _ThinOutMaskTex);

                    using (new EditorGUI.DisabledGroupScope(!IsEqualsTo(_ThinOutSource, (int) ThinOutSource.NoiseTexture)))
                    {
                        me.TexturePropertySingleLine(new GUIContent("Noise Texture *"), _ThinOutNoiseTex);
                        me.ShaderProperty(_ThinOutNoiseThresholdR, "Noise Threshold R *");
                        me.ShaderProperty(_ThinOutNoiseThresholdG, "Noise Threshold G *");
                        me.ShaderProperty(_ThinOutNoiseThresholdB, "Noise Threshold B *");
                    }

                    using (new EditorGUI.DisabledGroupScope(!IsEqualsTo(_ThinOutSource, (int) ThinOutSource.ShaderProperty)))
                        me.ShaderProperty(_ThinOutMinSize, "Voxel Minimal Size *");
                }
            }
        }

        private void OnStencilGui(MaterialEditor me)
        {
            using (new Section("Stencil"))
            {
                GUILayout.Label("Stencil", EditorStyles.boldLabel);

                me.ShaderProperty( _StencilReference, "Reference");
                me.ShaderProperty(_StencilCompare, "Compare");
                me.ShaderProperty(_StencilPass, "Pass");
                me.ShaderProperty(_StencilFail, "Fail");
                me.ShaderProperty(_StencilZFail, "ZFail");
            }
        }

        private void OnOthersGui(MaterialEditor me)
        {
            using (new Section("Others"))
            {
                GUILayout.Label("Shader Settings", EditorStyles.boldLabel);

                me.ShaderProperty(_Culling, "Culling");
                me.ShaderProperty(_ZWrite, "ZWrite");
                me.RenderQueueField();
            }
        }

        private static bool IsEqualsTo(MaterialProperty a, int b)
        {
            return b - 0.5 < a.floatValue && a.floatValue <= b + 0.5;
        }

        private static bool IsEqualsTo(MaterialProperty a, bool b)
        {
            return IsEqualsTo(a, b ? 1 : 0);
        }

        private class Section : IDisposable
        {
            private readonly IDisposable _disposable;

            public Section(string title)
            {
                GUILayout.Label(title, EditorStyles.boldLabel);
                _disposable = new EditorGUILayout.VerticalScope(GUI.skin.box);
            }

            public void Dispose()
            {
                _disposable.Dispose();
            }
        }

        // ReSharper disable InconsistentNaming

        private MaterialProperty _Alpha;
        private MaterialProperty _Culling;
        private MaterialProperty _EnableAnimation;
        private MaterialProperty _EnableThinOut;
        private MaterialProperty _EnableVoxelization;
        private MaterialProperty _MainTex;
        private MaterialProperty _StencilCompare;
        private MaterialProperty _StencilFail;
        private MaterialProperty _StencilPass;
        private MaterialProperty _StencilReference;
        private MaterialProperty _StencilZFail;
        private MaterialProperty _ThinOutMaskTex;
        private MaterialProperty _ThinOutMinSize;
        private MaterialProperty _ThinOutNoiseTex;
        private MaterialProperty _ThinOutNoiseThresholdB;
        private MaterialProperty _ThinOutNoiseThresholdG;
        private MaterialProperty _ThinOutNoiseThresholdR;
        private MaterialProperty _ThinOutSource;
        private MaterialProperty _UVSamplingSource;
        private MaterialProperty _VoxelMinSize;
        private MaterialProperty _VoxelOffsetN;
        private MaterialProperty _VoxelOffsetX;
        private MaterialProperty _VoxelOffsetY;
        private MaterialProperty _VoxelOffsetZ;
        private MaterialProperty _VoxelSize;
        private MaterialProperty _VoxelSource;
        private MaterialProperty _ZWrite;

        // ReSharper restore InconsistentNaming
    }

    public class ToggleWithoutKeywordDrawer : MaterialPropertyDrawer
    {
        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
            EditorGUI.BeginChangeCheck();

            var value = EditorGUI.Toggle(position, label, prop.floatValue >= 0.5f);

            if (EditorGUI.EndChangeCheck())
                prop.floatValue = value ? 1.0f : 0.0f;
        }
    }
}