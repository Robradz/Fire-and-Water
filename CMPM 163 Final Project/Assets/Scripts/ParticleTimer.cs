using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticleTimer : MonoBehaviour
{
    [Header("Water and Fire particle systems")]
    [SerializeField] ParticleSystem[] waterParticles;
    [SerializeField] ParticleSystem[] fireParticles;

    // Update is called once per frame
    void Update()
    {
        ManageParticles();
    }

    private void ManageParticles()
    {
        double waterTimer = (-Math.Cos(Time.time / 4) + 1) / 2;
        double fireTimer = (1.2 * Math.Cos(Time.time / 4 + 3.2) + .8) / 1.6;
        ActivateWaterParticles(waterTimer, waterParticles);
        ActivateFireParticles(fireTimer, fireParticles);
    }

    private void ActivateFireParticles(double timer, ParticleSystem[] fireParticles)
    {
        for (int i = 0; i < fireParticles.Length; i++)
        {
            if ((Convert.ToDouble(i)) / (fireParticles.Length) < timer)
            {
                fireParticles[i].Stop();
            }
            else
            {
                if (fireParticles[i].isStopped)
                {
                    fireParticles[i].Play();
                }
            }
        }
    }

    private void ActivateWaterParticles(double timer, ParticleSystem[] waterParticles)
    {
        for (int i = 0; i < waterParticles.Length; i++)
        {
            if ((Convert.ToDouble(i) + 10.0) / (waterParticles.Length + 10) < timer)
            {
                if (waterParticles[i].isStopped)
                {
                    waterParticles[i].Play();
                }
            }
            else
            {
                waterParticles[i].Stop();
            }
        }
    }

    IEnumerator FadeLight(ParticleSystem fire, float startIntensity, float endIntensity)
    {
        float t = 0;
        float fadeTime = 1;
        Light l = fire.GetComponentInChildren<Light>();
        while (t < fadeTime)
        {
            t += Time.deltaTime;

            l.intensity = Mathf.Lerp(startIntensity, endIntensity, t / fadeTime);
            yield return new WaitForEndOfFrame();
        }
        yield break;
    }
}
